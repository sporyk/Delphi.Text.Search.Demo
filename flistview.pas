unit flistview;

interface

uses Windows, Classes, SysUtils, wlistview2, graphics, Controls, ComCtrls, ImgList;

type

    TFileListView = class(TWhiteListView)
    private
     FIL:TImageList;
    public
     procedure CustomDefaults;override;
     function selectItemFont(aCanvas:TCanvas; aState:TCustomDrawState; aRect:TRect; v:TListItem; row,index:integer):THandle;override;
     function getColumnItemData(v: TListItem; aRect: TRect; row, index: Integer): WideString;override;
     procedure drawSelectedItem(aCanvas:TCanvas; aRect:TRect; v: TListItem);override;
     procedure predrawCustomColumnItem(aCanvas:TCanvas;aState:TCustomDrawState; aRect:TRect; v:TListItem; index:integer);override;
     function  customTextFormatFlags(aTextFormat:DWORD;aCanvas:TCanvas; aState:TCustomDrawState; aRect:TRect; v:TListItem; row,index:integer):DWORD;override;

     property imagelist:TImageList read FIL write FIL;
    end;

    procedure scrollList(lv: TListView; ListIndex: Integer);
    function updateLVitem(lv:TListView;i:integer):boolean;

implementation

uses emergency, efileapi;

procedure scrollList(lv: TListView; ListIndex: Integer);
begin
 wlistview2.scrollList(lv,listindex);
end;

function updateLVitem(lv:TListView;i:integer):boolean;
begin
 Result:=wlistview2.updateLVitem(lv,i);
end;

function SizeToStr(Size:Int64):WideString;
begin
 Result:='0 Bytes';
 if Size=0 then Exit;
 if Size>=1073741824 then
  begin
   Result:=Format('%f GB',[Size/1073741824]);
   Exit;
  end;
 if Size>=1048576 then
  begin
   Result:=Format('%f MB',[Size/1048576]);
   Exit;
  end;
 if Size>=1024 then
  begin
   Result:=Format('%f Kb',[Size/1024]);
   Exit;
  end;
 Result:=Format('%d Bytes',[Size]);
end;

procedure drawBox(aCanvas:TCanvas;aRect:TRect;FillWidth:Integer=-1);
var
 r:TRect;
 i,w,h:integer;
 bc,pc:TColor;
begin
 with aCanvas do
  begin
   bc:=Brush.Color;
   pc:=Pen.Color;
   r:=aRect;inflateRect(r,-2,-2);
   brush.color:=clWhite; // bc
   Pen.Color:=$00937544;
   RoundRect(aRect.Left,aRect.Top,aRect.Right{+1},aRect.Bottom,2,2);
   FillRect(r);
   h:=r.Bottom-r.Top;
   for i:=0 to h+1 do
    begin
     pen.Color:=RGB(252-i,194-(i*2),94-(i*2));
     moveto(r.Left-1,r.Top+i-1);
     if FillWidth=0 then begin end
      else if FillWidth=-1 then lineto(r.Right+1,r.Top+i-1)
       else
         begin
          w:=r.Left-1+FillWidth;
          if w>r.Right+1 then w:=r.Right+1;
          lineto(w,r.Top+i-1);
          pen.color:=clWhite; //bc
          lineto(r.Right+1,r.Top+i-1);
         end;
    end;
   Brush.Color:=bc;
   Pen.Color:=pc;
  end;
end;

procedure drawProgress(aCanvas:TCanvas;x,y,w,progress:Integer;Boxed:Boolean=True);
const wbox = 20; hbox = 7;
var
 i,c,p:integer;
 r:TRect;
begin
 //if progress>0 then
  case Boxed of
   True:begin
         c:=w div (wbox+1);
         p:=(c*progress) div 100;
         r:=Rect(x,y,x+wbox,y+hbox);
         with aCanvas do FillRect(Rect(x,y,x+(wbox+2)*c,y+hbox));
         if p>0 then
          for i:=0 to c-1 do
           begin
            drawBox(aCanvas,r);
            offsetRect(r,1+wbox+1,0);
            if i>=p then Break;
           end;
        end;
   False:begin
          r:=Rect(x,y,x+w,y+hbox);
          InflateRect(r,-2,0);
          with aCanvas do FillRect(r);
          drawBox(aCanvas,r,(w*progress) div 100); // progress is percent
         end;
  end;
end;

{ TScanningLV }

procedure TFileListView.CustomDefaults;
var lf:TLOGFont;
begin
 Color:=RGB(244,247,252);

 MultiColorLines:=True;
 LinesColor1:=RGB(244,247,252);
 LinesColor2:=RGB(240,240,250);

 RowHeight:=20;

 Font.Name:='Arial';
 HeaderFontColor:=$007B534A;

 Filters:=False;
 DividerLine:=False;
 SelectionMark:=True;

 ItemsFont.Size:=9;
 ItemsFont.Color:=clBlack;//$00937544;
 ItemsFont.Style:=[];

 Font.Size:=10;
 if GetColumnsFont(lf) then
  begin
   lf.lfWeight:=FW_BOLD;
   lf.lfUnderline:=0;
   lf.lfOutPrecision:=OUT_TT_ONLY_PRECIS;
   if sysutils.Win32MajorVersion>=6 then lf.lfQuality:=CLEARTYPE_QUALITY else lf.lfQuality:=ANTIALIASED_QUALITY;
   SetColumnsFont(lf);
  end;
  
end;

function TFileListView.customTextFormatFlags(aTextFormat: DWORD; aCanvas: TCanvas; aState: TCustomDrawState; aRect: TRect; v: TListItem; row, index: integer): DWORD;
begin
 Result:=inherited customTextFormatFlags(aTextFormat,aCanvas,aState,aRect,v,row,index);
 if index=1 then Result:=Result or DT_END_ELLIPSIS or DT_PATH_ELLIPSIS;
end;

procedure TFileListView.drawSelectedItem(aCanvas: TCanvas; aRect: TRect; v: TListItem);
begin
 with aCanvas do
  begin
   Pen.Color:=RGB(210,210,220);
   Rectangle(aRect);
  end;
end;

function TFileListView.getColumnItemData(v: TListItem; aRect: TRect; row, index: Integer): WideString;
begin
 if Assigned(v.Data) then
  begin
   if (TObject(v.Data) is TFileListEntry) then
    begin
     case index of
      1:Result:=TFileListEntry(v.Data).displayname;
      2:Result:=SizeToStr(FileSizeW(TFileListEntry(v.Data).filename));
      3:Result:='';//Progress
      4:if TFileListEntry(v.Data).active then Result:='Processing' else Result:=TFileListEntry(v.Data).conditionsDesc;//Status
     end;
    end;
  end else Result:=inherited getColumnItemData(v,aRect,row, index);
end;

procedure TFileListView.predrawCustomColumnItem(aCanvas: TCanvas; aState: TCustomDrawState; aRect: TRect; v: TListItem; index: integer);
var _level:integer;
begin
 if Assigned(imagelist) and (v.ImageIndex>-1) then imagelist.Draw(aCanvas,aRect.Left+1,aRect.Top+1,v.ImageIndex);
 
 _level:=0;
 if (TObject(v.Data) is TFileListEntry) then
  with TFileListEntry(v.Data) do
   begin
    if max=0 then _level:=0
     else if (max>0) and (progress=max) then _level:=100
      else _level:=Round((progress/max)*100);
   end;

 drawProgress(aCanvas,aRect.Left+v.ListView.Column[0].width+v.ListView.Column[1].width+v.ListView.Column[2].width,aRect.Top+6,v.ListView.Column[3].width,_level,False);
end;

function TFileListView.selectItemFont(aCanvas: TCanvas; aState: TCustomDrawState; aRect: TRect; v: TListItem; row,index: integer):THandle;
var logRec:TLOGFONT;
begin
 if not v.Selected then Result:=inherited selectItemFont(aCanvas,aState,aRect,v,row,index)
  else
   begin
    GetObject(aCanvas.Font.Handle,SizeOf(LogRec),@LogRec);
    logRec.lfWeight:=FW_BOLD;
    if sysutils.Win32MajorVersion>=6 then logRec.lfQuality:=CLEARTYPE_QUALITY else logRec.lfQuality:=ANTIALIASED_QUALITY;
    logRec.lfOutPrecision:=OUT_TT_PRECIS;
    Result:=CreateFontIndirect(logRec);

    SetTextColor(aCanvas.Handle,clRed);
   end;
end;

end.
