unit search;

interface

uses WinApi.Windows, System.SysUtils, System.Classes, fileTools;

type

     TFileLocation = fileTools.TFileLocation;
     PFileLocation = ^TFileLocation;

     TTextEcncodingType = (encASCII, encUTF8, encUTF16);
     TSearchField = (ffFolder,ffTime,ffFileAttr,ffFileSize,ffFileText);
     TSearchFields = set of TSearchField;

     TSearchParameters = packed record
      path,mask:WideString;
      recursive:boolean;
      attr:DWORD;
      minSize,maxSize:Int64;
      minTime,maxTime:TDateTime;
      text:WideString;
      enc:TTextEcncodingType;
      fields:TSearchFields;

      procedure search(aFolder:WideString;aFileMask:WideString='*.*');
      procedure constraintTime(v:array of TDateTime);
      procedure constraintFileAttributes(v:DWORD);
      procedure constraintFileSize(aMin:Int64;aMax:Int64);
      procedure constraintFileContent(aText:WideString;aEncoding:TTextEcncodingType=encASCII);
     end;

     TSearchOperation = class(TThread)
     private
      FEOS:THandle;
      FQuery:TSearchQuery;
      FOnNewItemFound:TNotifyEvent;
     public
      constructor Create(aParameters:TSearchParameters;aOnNewItemFound:TNotifyEvent=nil);reintroduce;
      destructor Destroy;override;

      procedure Execute;override;

      property eos:THandle read FEOS write FEOS;
     end;

implementation

uses System.WideStrUtils;

{ TSearchParameters }

procedure TSearchParameters.constraintFileAttributes(v: DWORD);
begin

end;

procedure TSearchParameters.constraintFileContent(aText: WideString; aEncoding: TTextEcncodingType);
begin

end;

procedure TSearchParameters.constraintFileSize(aMin, aMax: Int64);
begin

end;

procedure TSearchParameters.constraintTime(v: array of TDateTime);
begin

end;

procedure TSearchParameters.search(aFolder, aFileMask: WideString);
begin

end;

{ TSearchOperation }

constructor TSearchOperation.Create(aParameters: TSearchParameters; aOnNewItemFound: TNotifyEvent);
var m:WideString;
begin
 inherited Create(True);
 FOnNewItemFound:=aOnNewItemFound;

 if trim(aParameters.mask)<>'' then m:=aParameters.mask;
 FQuery.create(aParameters.path,m);
 FQuery.recursive:=aParameters.recursive;

end;

destructor TSearchOperation.Destroy;
begin
 FOnNewItemFound:=nil;
 inherited Destroy;
end;

procedure TSearchOperation.Execute;
var
 location:TFileLocation;
 buf:Pointer;
begin
 while not findNextFile(FQuery,location) do
  begin
   buf:=AllocMem(SizeOf(TFileLocation));
   TFileLocation(buf^).path:=PWidechar(AllocMem(WStrLen(location.path)));
   WStrCopy(TFileLocation(buf^).path,location.path);
   TFileLocation(buf^).data:=location.data;


   if Assigned(FOnNewItemFound) then FOnNewItemFound(@location);
  end;
 SetEvent(FEOS); // report end of the scan
end;

end.
