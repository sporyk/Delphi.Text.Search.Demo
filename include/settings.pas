unit settings;

interface

uses Windows, Classes, SysUtils, xmlObjects;

type
      TSettings = class(TPersistent)
      private
       FChanged:boolean;
       FParser:TXMLParser;
       FXMLFile:WideString;
      private
       function getAttribute(path: WideString): WideString;
       procedure setAttribute(path: WideString; const Value: WideString);
      public
       constructor Create(aXMLFile:WideString);reintroduce;
       destructor Destroy;override;

       procedure beginTransaction;
       procedure endTransaction;

       property parser:TXMLParser read FParser;
       property attribute[path:WideString]:WideString read getAttribute write setAttribute;
      end;

      function readSettings(aXmlFile:WideString;aParameterXPath:WideString):WideString;
      function writeSettings(aXmlFile:WideString;aParameterXPath:WideString;aValue:WideString=''):boolean;


implementation

{ utility functions }

function readSettings(aXmlFile:WideString;aParameterXPath:WideString):WideString;
var
 s:TSettings;
 a,p:WideString;
 e:TXMLElement;
begin
 Result:='';
 p:=copy(aParameterXPath,1,Pos('@',aParameterXPath)-1);
 a:=copy(aParameterXPath,Pos('@',aParameterXPath)+1,length(aParameterXPath)-pos('@',aParameterXPath));
 if trim(p)='' then Exit;
 s:=TSettings.Create(aXmlFile);
 if Assigned(s.parser) then
  if Assigned(s.parser.document) then
   begin
    e:=s.parser.document.element[p];
    if Assigned(e) then if e.ifattribute[a] then Result:=e.attribute[a];
   end; 
 s.Free;
end;

function writeSettings(aXmlFile:WideString;aParameterXPath:WideString;aValue:WideString=''):boolean;
var
 s:TSettings;
 a,p,m,mm:WideString;
 e,pp:TXMLElement;
begin
 Result:=False;

 p:=copy(aParameterXPath,1,Pos('@',aParameterXPath)-1);
 a:=copy(aParameterXPath,Pos('@',aParameterXPath)+1,length(aParameterXPath)-pos('@',aParameterXPath));
 if trim(p)='' then Exit;

 s:=TSettings.Create(aXmlFile);
 if Assigned(s.parser) then
  if not Assigned(s.parser.document) then s.parser.generateRoot('DsSettings');
 e:=s.parser.document.element[p];
 if not Assigned(e) then
  begin
   m:=p;
   if m[length(m)]='/' then m:=trim(copy(m,1,length(m)-1)) else m:=trim(m);
   pp:=s.parser.document;
   repeat
    mm:=copy(m,1,pos('/',m)-1);if (mm='') and (m<>'') then mm:=m;
    if Assigned(pp.element[mm]) then pp:=pp.element[mm] else pp:=pp.newelement(mm);
    e:=pp;
    if pos('/',m)>0 then m:=copy(m,pos('/',m)+1,length(m)-pos('/',m)) else m:='';
   until trim(m)='';
   s.FChanged:=True;// little hack to force write
  end;

 if Assigned(e) then
  begin
   s.beginTransaction;
   if not e.ifattribute[a] then e.newattribute(a,aValue) else e.attribute[a]:=aValue;
   s.FChanged:=True;
   s.endTransaction;
  end;

 e:=s.parser.document.element[p];
 Result:=Assigned(e) and e.ifattribute[a];

 s.Free;
end;

{ TSettings }

procedure TSettings.beginTransaction;
begin
 if FChanged then endTransaction; // not clean but safe
end;

constructor TSettings.Create(aXMLFile: WideString);
var hres:DWORD;
begin
 inherited Create;
 FXMLFile:=aXMLFile;
 FParser:=TXMLParser.Create;
 hres:=windows.GetFileAttributesW(PWideChar(aXMLFile));
 if (hres<>$FFFFFFFF) and (hres and FILE_ATTRIBUTE_DIRECTORY<>FILE_ATTRIBUTE_DIRECTORY) then FParser.loadFile(aXMLFile);
 FChanged:=False;
end;

destructor TSettings.Destroy;
begin
 if FChanged then endTransaction;
 if Assigned(FParser) then FParser.Free;
 FParser:=nil;
 inherited Destroy;
end;

procedure TSettings.endTransaction;
var s:TFileStream;
begin
 if FChanged then
  begin
   if Assigned(FParser) then
    begin
     s:=TFileStream.Create(FXMLFile,fmCreate);
     s.seek(0,0); // in case file exists
     FParser.save(s);
     s.Free;
    end;
   FChanged:=False;
  end;
end;

function TSettings.getAttribute(path: WideString): WideString;
var
 a,p:WideString;
 e:TXMLElement;
begin
 Result:='';
 if trim(path)='' then Exit;
 if Assigned(FParser) then
  begin
   p:=copy(path,1,Pos('@',path)-1);
   a:=copy(path,Pos('@',path)+1,length(path)-pos('@',path));
   e:=FParser.document.element[p];
   if Assigned(e) then if e.ifattribute[a] then Result:=e.attribute[a];
  end;
end;

procedure TSettings.setAttribute(path: WideString; const Value: WideString);
var
 a,p,m,mm:WideString;
 e,pp:TXMLElement;
begin
 if trim(path)='' then Exit;
 if Assigned(FParser) then
  begin
   p:=trim(copy(path,1,Pos('@',path)-1));
   if p='' then Exit;
   a:=copy(path,Pos('@',path)+1,length(path)-pos('@',path));
   e:=FParser.document.element[p];
   if not Assigned(e) then // Path elements traversal
    begin
     m:=p;
     if m[length(m)]='/' then m:=trim(copy(m,1,length(m)-1)) else m:=trim(m);
     pp:=FParser.document;
     repeat
      mm:=copy(m,1,pos('/',m)-1);if (mm='') and (m<>'') then mm:=m;
      if Assigned(pp.element[mm]) then pp:=pp.element[mm] else pp:=pp.newelement(mm);
      e:=pp;
      if pos('/',m)>0 then m:=copy(m,pos('/',m)+1,length(m)-pos('/',m)) else m:='';
     until trim(m)='';
    end;
   if Assigned(e) then if not e.ifattribute[a] then e.newattribute(a,Value) else e.attribute[a]:=Value;
   FChanged:=true;
  end;
end;

end.
