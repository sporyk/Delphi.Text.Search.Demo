unit search;

interface

uses WinApi.Windows, System.SysUtils, System.Classes, fileTools;

type

     TTextEcncodingType = (encASCII, encUTF8, encUTF16);
     TSearchField = ();
     TSearchFields = set of TSearchField;

     TSearchParameters = packed record
      path:WideString;
      fields:TSearchFields;

      procedure search(aFolder:WideString;aFileMask:WideString='*.*');
      procedure constraintTime(v:array of TDateTime);
      procedure constraintFileAttributes(v:DWORD);
      procedure constraintFileSize(aMin:Int64;aMax:Int64);
      procedure constraintFileContent(aText:WideString;aEncoding:TTextEcncodingType);
     end;

     TSearchOperation = class(TThread)
     private
      searchQuery:TSearchQuery;

     public
      constructor Create(aParameters:TSearchParameters;aOnNewItemFound:TNotifyEvent=nil);reintroduce;
      destructor Destroy;override;



     end;

implementation

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
begin

end;

destructor TSearchOperation.Destroy;
begin

  inherited;
end;

end.
