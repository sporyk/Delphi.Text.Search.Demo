unit xmlobjects;

interface

uses Windows, Classes, SysUtils;

type

   TXMLElement = class
   private
    FHost:TXMLElement;
    FXML,FRoot,FNodes:Variant;

    FList:TList;
    FTag:WideString;

    function getAttribute(tag: WideString): WideString;
    procedure setAttribute(tag: WideString; const Value: WideString);
    function getIfAttribute(tag: WideString): boolean;

    function getElement(tag: WideString): TXMLElement;

    function getText: WideString;
    procedure setText(const Value: WideString);

    function getName: WideString;
   public
    constructor Create(aOwner:TXMLElement;aRoot:Variant);
    destructor Destroy;override;

    function  newelement(tag:WideString;data:WideString=''):TXMLElement;
    procedure newattribute(tag,data:WideString);

    function next:boolean;

    property parent:Variant read FRoot;
    property ifattribute[tag:WideString]:boolean read getIfAttribute;
    property attribute[tag:WideString]:WideString read getAttribute write setAttribute;
    property element[tag:WideString]:TXMLElement read getElement;
    property text:WideString read getText write setText;
    property name:WideString read getName;

    property tag:WideString read FTag;
   end;

   TXMLParser = class
   private
    FRoot:TXMLElement;
    FXML:Variant;
   public
    constructor Create(engine:string='Microsoft.XMLDOM');
    destructor Destroy;override;

    function processingInstruction(aName:WideString;aValue:WideString=''):boolean;
    function generateRoot(aRootElementName:WideString):boolean;

    function load(s:TStream):Boolean;overload;
    function load(xml:WideString):Boolean;overload;
    function loadFile(filename:WideString):Boolean;
    function save(s:TStream):Boolean;

    property document:TXMLElement read FRoot;
   end;

   function VALID(v:Variant):Boolean;

implementation

uses ActiveX;

{ utils }

function iexist(v:Variant):Boolean;
begin
 Result:=Assigned(IDispatch(v));
end;

function VALID(v:Variant):Boolean;
begin
 Result:=Assigned(IDispatch(v));
end;

function CreateXMLObject(const ProgID:string):IDispatch;
var
 ClassID:TCLSID;
 dwClsContext:LongInt;
begin
 Result:=nil;
 dwClsContext:=CLSCTX_INPROC_SERVER;
 if ActiveX.CLSIDFromProgID(PWideChar(WideString(ProgID)),ClassID)=S_OK then
  if not SUCCEEDED(ActiveX.CoCreateInstance(ClassID,nil,dwClsContext,IDispatch,Result)) then Result:=nil;
end;

function FreeXMLObject(var v:Variant):Boolean;
begin
 v:=varNull;
 Result:=True;
end;

{ TXMLElement }

constructor TXMLElement.Create(aOwner: TXMLElement;aRoot: Variant);
begin
 FHost:=aOwner;
 FRoot:=aRoot;
 FXML:=varNull;

 FTag:='';
 FNodes:=varNull;

 FList:=TList.Create;
end;

destructor TXMLElement.Destroy;
var i:integer;
begin
 for i:=0 to FList.Count-1 do TXMLElement(FList[i]).Free;
 FList.Free;
 FNodes:=varNull;
 FRoot:=varNull;
 inherited Destroy;
end;

function TXMLElement.getAttribute(tag: WideString): WideString;
begin
 Result:=FRoot.attributes.getNamedItem(tag).text;
end;

function TXMLElement.getElement(tag: WideString): TXMLElement;
var e:Variant;
begin
 Result:=nil;
 if Assigned(IDispatch(FRoot)) then
  begin
   FTag:=tag;
   FNodes:=FRoot.selectNodes(FTag);
   if iexist(FNodes) then
    begin
     e:=FNodes.nextNode;
     if iexist(e) then
      begin
       Result:=TXMLElement.Create(Self,e);
       Result.FXML:=FXML;
       FList.Add(Result);
      end;
     e:=varNull;
    end else FNodes:=varNull;
  end;
end;

function TXMLElement.getIfAttribute(tag: WideString): boolean;
begin
 Result:=iexist(FRoot.attributes.getNamedItem(tag));
end;

function TXMLElement.getName: WideString;
begin
 if iexist(FRoot) then Result:=FRoot.nodeName else Result:='';
end;

function TXMLElement.getText: WideString;
begin
 if iexist(FRoot) then Result:=FRoot.text else Result:='';
end;

procedure TXMLElement.newattribute(tag, data: WideString);
var attr:Variant;
begin
 if iexist(FRoot) then
  begin
   attr:=FXML.createAttribute(tag);
   FRoot.setAttribute(tag,data);
   attr:=varNull;
  end;
end;

function TXMLElement.newelement(tag, data: WideString): TXMLElement;
var v:Variant;
begin
 Result:=nil;
 if iexist(FRoot) then
  begin
   v:=FXML.createElement(tag);
   FRoot.appendChild(v);
   if iexist(v) then
    begin
     Result:=TXMLElement.Create(Self,v);
     Result.FXML:=FXML;
     Result.text:=data;
     FList.Add(Result);
    end;
   v:=varNull;
  end;
end;

function TXMLElement.next: boolean;
var e:Variant;
begin
 Result:=False;
 if not iexist(FHost.FNodes) then FHost.FNodes:=FHost.FRoot.selectNodes(FTag);
 e:=FHost.FNodes.nextNode;
 if iexist(e) then
  begin
   FRoot:=e;
   Result:=True;
  end;
end;

procedure TXMLElement.setAttribute(tag: WideString; const Value: WideString);
var attr:Variant;
begin
 attr:=FRoot.attributes.getNamedItem(tag);
 if iexist(attr) then attr.text:=Value;
end;

procedure TXMLElement.setText(const Value: WideString);
begin
 if iexist(FRoot) then FRoot.text:=Value;
end;

{ TXMLParser }

constructor TXMLParser.Create(engine: string);
begin
 FRoot:=nil;
 FXml:=CreateXMLObject(engine);
 if not Assigned(IDispatch(FXml)) then FXml:=CreateXMLObject('Msxml2.DOMDocument.4.0');
end;

destructor TXMLParser.Destroy;
begin
 if Assigned(FRoot) then FRoot.Free; FRoot:=nil;
 FreeXMLObject(FXml);
 inherited Destroy;
end;

function TXMLParser.generateRoot(aRootElementName: WideString): boolean;
var v:Variant;
begin
 if Assigned(FRoot) then Result:=True
  else
   begin
    Result:=False;
    if iexist(FXml) then
     begin
      v:=FXML.createElement(aRootElementName);
      FRoot:=TXMLElement.Create(nil,v);
      FRoot.FXML:=FXML;
      FXML.appendChild(v);
      Result:=Assigned(FRoot);
     end;
   end;
end;

function TXMLParser.load(xml: WideString): Boolean;
begin
 Result:=False;
 if iexist(FXml) then
  begin
   FXML.async:=false;
   FXML.loadXML(xml);
   if iexist(FXML.DocumentElement) then
    begin
     FRoot:=TXMLElement.Create(nil,FXML.DocumentElement); // nil for root element
     FRoot.FXML:=FXML;
     Result:=True;
    end;
  end;
end;

function TXMlParser.loadFile(filename:WideString):Boolean;
begin
 Result:=False;
 if iexist(FXml) then
  begin
   FXML.async:=false;
   FXML.load(filename);
   if iexist(FXML.DocumentElement) then
    begin
     FRoot:=TXMLElement.Create(nil,FXML.DocumentElement); // nil for root element
     FRoot.FXML:=FXML;
     Result:=True;
    end;
  end;
end;

function TXMLParser.processingInstruction(aName: WideString; aValue: WideString): boolean;
var v:Variant;
begin
 Result:=false;
 if iexist(FXML) then
  begin
   v:=FXml.createProcessingInstruction(aName,aValue);
   FXML.appendChild(v);
  end;
end;

function TXMLParser.load(s: TStream): Boolean;
var i:IStream;
begin
 Result:=False;
 if iexist(FXml) then
  begin
   FXML.async:=False;
   i:=TStreamAdapter.Create(s);
   FXML.load(i);
   if iexist(FXML.DocumentElement) then
    begin
     FRoot:=TXMLElement.Create(nil,FXML.DocumentElement); // nil for root element
     FRoot.FXML:=FXML;
     Result:=True;
    end;
  end;
end;

function TXMLParser.save(s: TStream): boolean;
var i:IStream;
begin
 if iexist(FXml) then
  begin
   FXML.async:=False; // saving
   i:=TStreamAdapter.Create(s);
   FXML.save(i);
   Result:=True;
  end else Result:=False;
end;

initialization
 CoInitialize(nil);
end.
