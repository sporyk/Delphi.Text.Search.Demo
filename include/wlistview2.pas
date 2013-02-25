unit wlistview2;

interface

uses Windows, Classes, SysUtils, Types, Controls, CommCtrl, ComCtrls, Graphics, Messages;

const

  CLEARTYPE_NATURAL_QUALITY = 6;
  ANTIALIASED_QUALITY    = 4;
  CLEARTYPE_QUALITY      = 5;
  DEFAULT_QUALITY        = 0;
  DRAFT_QUALITY          = 1;
  NONANTIALIASED_QUALITY = 4;
  PROOF_QUALITY          = 2;

type

  TColumnResizeEvent = procedure(Sender:TObject;columnIndex,columnWidth:Integer) of object;

  TWhiteListView = class(TListView)
  private
   hwndHeader:HWND;
  private
   FMultiColorLines,FFilters,FDividerLine,FSelectionMark:Boolean;
   FLinesColor1,FLinesColor2:TColor;

   FLocked:boolean;

   FHeaderHeight:integer;
   FHDFontColor: TColor;
   hHeaderFont:THandle;
   FItemsFont:TFont;

   FOnBeginColumnResize,FOnEndColumnResize,FOnColumnResize:TColumnResizeEvent;

   FHeaderInstance,oldHeaderWndProc:Pointer;

   function getRH: Integer;
   procedure setRH(const Value: Integer);

   //procedure IntCustomDraw(Sender:TCustomListView;const aRect:TRect;var DefaultDraw:Boolean);
   procedure IntCustomDrawItem(Sender:TCustomListView;Item:TListItem;State:TCustomDrawState;var DefaultDraw:Boolean);
   procedure IntMouseMove(Sender:TObject;Shift:TShiftState;X,Y:Integer);

   procedure SetFilters(const Value: Boolean);
   function GetHeaderHeight: integer;
   procedure SetHeaderHeight(const Value: integer);

   function _findColumnIndex(pHeader:pNMHdr):integer;
   function _findColumnWidth(pHeader:pNMHdr):integer;
  protected
   //procedure WMNCPaint(var Message:TMessage); message WM_NCPAINT;
   procedure newHeaderWndProc(var Message:TMessage);virtual;
  public
   constructor Create(AOwner: TComponent);override;
   destructor Destroy;override;

   procedure postCreate;virtual;
   procedure preDestroy;virtual;
   procedure CustomDefaults;virtual;

   procedure drawCustomHeaderBackground(aCanvas:TCanvas; aRect:TRect; aIndex,aState:integer);virtual;
   function CustomHeaderTextAlignment(aRect:TRect;aIndex:integer):DWORD;virtual;
   function CustomHeaderRectAdjustment(aRect:TRect;aIndex:integer):TRect;virtual;

   procedure doBeginColumnResize(columnindex,columnwidth:integer);virtual;
   procedure doEndColumnResize(columnindex,columnwidth:integer);virtual;
   procedure doColumnResize(columnindex,columnwidth:integer);virtual;

   procedure drawItemBackground(aCanvas:TCanvas; aRect:TRect; v:TListItem);virtual;
   procedure drawSelectedItem(aCanvas:TCanvas; aRect:TRect; v:TListItem);virtual;
   function  getItemRows(v:TListItem):integer;virtual;
   procedure getColumnItemRect(v:TListItem;aRect:TRect;var r:TRect;row,index:Integer);virtual;
   function  getColumnItemData(v:TListItem;aRect:TRect;row,index:Integer):WideString;virtual;
   function  selectItemFont(aCanvas:TCanvas; aState:TCustomDrawState; aRect:TRect; v:TListItem; row,index:integer):THandle;virtual;
   procedure predrawCustomColumnItem(aCanvas:TCanvas;aState:TCustomDrawState; aRect:TRect; v:TListItem; index:integer);virtual;
   function  customTextFormatFlags(aTextFormat:DWORD;aCanvas:TCanvas; aState:TCustomDrawState; aRect:TRect; v:TListItem; row,index:integer):DWORD;virtual;
   procedure drawCustomListItem(aCanvas:TCanvas; aState:TCustomDrawState; aRect:TRect; v:TListItem);virtual;

   function GetColumnsFont(out v:TLOGFONT):Boolean;
   procedure SetColumnsFont(v:TLOGFONT);

   function getHeaderData(c:integer):THDItem;
   function getItemRect(aRect:TRect;index:integer):TRect;

   procedure customListOnResize(Sender: TObject);virtual;
   procedure customListOnColumnResize(Sender:TObject;cIndex,cWidth:integer);virtual;

   property BevelKind;
   property BevelWidth;
   property BorderStyle;
   property BorderWidth;
   property Checkboxes;

   property RowHeight:Integer read getRH write setRH;
   property HeaderFontColor:TColor read FHDFontColor write FHDFontColor;
   property HeaderHeight:integer read GetHeaderHeight write SetHeaderHeight;

   property MultiColorLines:Boolean read FMultiColorLines write FMultiColorLines;
   property Filters:Boolean read FFilters write SetFilters;
   property DividerLine:Boolean read FDividerLine write FDividerLine;
   property SelectionMark:Boolean read FSelectionMark write FSelectionMark;

   property Locked:boolean read FLocked write FLocked;
   property ItemsFont:TFont read FItemsFont;
   property LinesColor1:TColor read FLinesColor1 write FLinesColor1;
   property LinesColor2:TColor read FLinesColor2 write FLinesColor2;

   property OnBeginColumnResize:TColumnResizeEvent read FOnBeginColumnResize write FOnBeginColumnResize;
   property OnEndColumnResize:TColumnResizeEvent read FOnEndColumnResize write FOnEndColumnResize;
   property OnColumnResize:TColumnResizeEvent read FOnColumnResize write FOnColumnResize;
  end;

  procedure scrollList(lv: TListView; ListIndex: Integer);
  function updateLVitem(lv:TListView;i:integer):boolean;
  procedure upgradeImageList(ImageList:TImageList);

implementation

uses Forms{$IFDEF WIN95UNICODE},uni95{$ENDIF};

{ utils }

procedure scrollList(lv: TListView; ListIndex: Integer);
var p:TPoint;
begin
 if lv=nil then Exit;
 if ListView_GetItemPosition(lv.Handle,ListIndex,p) then
  begin
   lv.Scroll(0,p.Y);
   lv.ItemFocused:=lv.Items.Item[ListIndex];
  end;
end;

function updateLVitem(lv:TListView;i:integer):boolean;
begin
 Result:=ListView_RedrawItems(lv.Handle,i,i);
end;

procedure upgradeImageList(ImageList:TImageList);
var
 IL:TImageList;
 Flags:LongWord;
begin
 Flags:=ILC_MASK or ILC_COLOR32;
 IL:=TImageList.Create(nil);
 try
  IL.Assign(ImageList);
  with ImageList do Handle:=ImageList_Create(Width,Height,Flags,Count,AllocBy);
  ImageList.Assign(IL);
 finally
  IL.Free;
 end;
end;

{ TWhiteListView }

{$REGION 'WhiteListView'}

  const HDS_FILTERBAR = $0100;

  constructor TWhiteListView.Create(AOwner: TComponent);
  begin
   inherited;
   Color:=clWhite;
   ViewStyle:=vsReport;
   ReadOnly:=True;
   RowSelect:=True;
   HideSelection:=False;
   ShowColumnHeaders:=True;
   BorderStyle:=bsNone;
   BevelKind:=bkNone;
   FlatScrollBars:=True;
   FLocked:=False;
   OnCustomDrawItem:=IntCustomDrawItem;
   //OnCustomDraw:=IntCustomDraw;
   OnMouseMove:=IntMouseMove;

   if not Assigned(Parent) then Parent:=TWinControl(aOwner);

   ListView_SetExtendedListViewStyle(Handle,ListView_GetExtendedListViewStyle(Handle) or LVS_EX_HEADERDRAGDROP);
   smallImages:=TImageList.Create(Self);
   hwndHeader:=SendMessage(Handle,LVM_GETHEADER,0,0);
   GetHeaderHeight;

   //SetLength(FColumnsRows,Columns.Count);
   //for i:=0 to Columns.Count-1 do FColumnsRows[i]:=1; // at least one column

   FItemsFont:=TFont.Create;
   //custom settings
   CustomDefaults;
   if FFilters then SetWindowLong(hwndHeader,GWL_STYLE,GetWindowLong(hwndHeader,GWL_STYLE) or HDS_FILTERBAR);

   FHeaderInstance:=Classes.MakeObjectInstance(newHeaderWndProc);
   oldHeaderWndProc:=Pointer(GetWindowLong(hwndHeader,GWL_WNDPROC));
   SetWindowLong(hwndHeader,GWL_WNDPROC,LongInt(FHeaderInstance));

   //oldWndProc:=Self.WindowProc;
   //Self.WindowProc:=newWndProc;
   postCreate;
  end;
  
  procedure TWhiteListView.CustomDefaults;
  var lf:TLOGFont;
  begin
   FMultiColorLines:=False;
   FLinesColor1:=clWhite;
   FLinesColor2:=TColor($00F0EAD0);

   FHDFontColor:=TColor($00937544);
   FItemsFont.Size:=8;
   FItemsFont.Style:=[fsBold];  
   FItemsFont.Color:=FHDFontColor-10000; 

   FFilters:=False;
   FDividerLine:=False;
   FSelectionMark:=False;

   Font.Size:=9;
   RowHeight:=20;
   if GetColumnsFont(lf) then
    begin
     lf.lfWeight:=FW_BOLD;
     lf.lfUnderline:=1;
     lf.lfOutPrecision:=OUT_TT_ONLY_PRECIS; 
     lf.lfQuality:=CLEARTYPE_NATURAL_QUALITY;  
     SetColumnsFont(lf);
    end;
  end;
  
  function TWhiteListView.CustomHeaderTextAlignment(aRect: TRect; aIndex: integer): DWORD;
  begin
   case Self.Column[aIndex].Alignment of
    taLeftJustify:Result:=DT_SINGLELINE or DT_LEFT or DT_VCENTER or DT_END_ELLIPSIS;
    taRightJustify:Result:=DT_SINGLELINE or DT_RIGHT or DT_VCENTER or DT_END_ELLIPSIS;
    taCenter:Result:=DT_SINGLELINE or DT_CENTER or DT_VCENTER or DT_END_ELLIPSIS;
   else Result:=DT_SINGLELINE or DT_END_ELLIPSIS;
   end;
  end;

  function TWhiteListView.CustomHeaderRectAdjustment(aRect: TRect; aIndex: integer): TRect;
  begin
   Result:=aRect;
  end;

  procedure TWhiteListView.customListOnColumnResize(Sender: TObject; cIndex, cWidth: integer);
  begin
   if GetAsyncKeyState(VK_MENU)<0 then
    begin
     if Assigned(Sender) and (Sender is TListView) then updateLVitem(TListView(Sender),TListView(Sender).Selected.Index);
     Exit; // Alt resize allowed
    end;
   if Assigned(Sender) and (Sender is TListView) then
    begin
     if TListView(Sender).Columns.Count<=1 then Exit;

     if cIndex=TListView(Sender).Columns.Count-1 then // last column
      begin
       with TListView(Sender).Columns[cIndex-1] do
        begin
         Width:=Width-(TListView(Sender).Columns[cIndex-1].Width-cWidth);
         if Width<10 then Width:=10;
        end;
      end
     else
      begin
       with TListView(Sender).Columns[cIndex+1] do
        begin
         Width:=Width+(cWidth-TListView(Sender).Columns[cIndex+1].Width);
         if Width<10 then Width:=10;
        end;
      end;
     updateLVitem(TListView(Sender),TListView(Sender).Selected.Index);
    end;
  end;

  procedure TWhiteListView.customListOnResize(Sender: TObject);
  var i,j,w,sz:integer;
  begin
   if Assigned(Sender) and (Sender is TListView) then
    begin
     w:=TListView(Sender).ClientWidth;
     sz:=0;
     j:=0;
     for i:=0 to TListView(Sender).Columns.Count-1 do
      if TListView(Sender).Columns[i].Tag=1 then j:=i else sz:=sz+TListView(Sender).Columns[i].Width;
     TListView(Sender).Columns[j].Width:=w-sz;

     w:=0;
     for i:=0 to TListView(Sender).Columns.Count-1 do w:=w+TListView(Sender).Columns[i].Width;
     if w<TListView(Sender).ClientWidth then ShowScrollBar(TListView(Sender).Handle,SB_HORZ,False); // hide horizontal scrolls
   end;
  end;

  function TWhiteListView.customTextFormatFlags(aTextFormat: DWORD; aCanvas: TCanvas; aState: TCustomDrawState; aRect: TRect; v: TListItem; row, index: integer): DWORD;
  begin
   Result:=aTextFormat;
  end;

  destructor TWhiteListView.Destroy;
  begin
   if hHeaderFont<>0 then DeleteObject(hHeaderFont);
   if Assigned(Self.SmallImages) then Self.SmallImages.Free;
   FItemsFont.Free;

   if hwndHeader<>0 then SetWindowLong(hwndHeader,GWL_WNDPROC,LongInt(oldHeaderWndProc));
   Classes.FreeObjectInstance(FHeaderInstance);

   preDestroy;
   inherited Destroy;
  end;

  procedure TWhiteListView.drawCustomListItem(aCanvas: TCanvas; aState: TCustomDrawState; aRect: TRect; v: TListItem);
  var
   m:TRect;
   FHandleNew,FHandleOld:THandle;
   i,j:integer;
   a:WideString;
   dwFormatText:DWORD;
  begin
   if Locked then Exit;
   aCanvas.Font.Assign(FItemsFont);
   SetBkMode(aCanvas.Handle,TRANSPARENT);
   for i:=0 to TListView(v.ListView).Columns.Count-1 do
    begin
     if Locked then Break;
     predrawCustomColumnItem(aCanvas,aState,aRect,v,i);
     for j:=0 to getItemRows(v)-1 do
      begin
       if Locked then Break;
       a:=getColumnItemData(v,aRect,j,i);
       getColumnItemRect(v,aRect,m,j,i);
       FHandleNew:=selectItemFont(aCanvas,aState,m,v,j,i);
       FHandleOld:=SelectObject(aCanvas.Handle,FHandleNew);
       case TListView(v.ListView).Columns[i].Alignment of
        taLeftJustify:dwFormatText:=DT_END_ELLIPSIS or DT_LEFT or DT_SINGLELINE or DT_VCENTER;
        taRightJustify:dwFormatText:=DT_END_ELLIPSIS or DT_RIGHT or DT_SINGLELINE or DT_VCENTER;
        taCenter:dwFormatText:=DT_END_ELLIPSIS or DT_CENTER or DT_SINGLELINE or DT_VCENTER;
        else dwFormatText:=DT_END_ELLIPSIS;
        end;
        dwFormatText:=customTextFormatFlags(dwFormatText,aCanvas,aState,m,v,j,i);
       {$IFDEF WIN95UNICODE}safeDrawTextW(aCanvas.Handle,PWideChar(a),Length(a),m,dwFormatText){$ELSE}DrawTextW(aCanvas.Handle,PWideChar(a),Length(a),m,dwFormatText){$ENDIF};
       FHandleNew:=SelectObject(aCanvas.Handle,FHandleOld);
       DeleteObject(FHandleNew);
      end;
    end;
  end;

  procedure TWhiteListView.doBeginColumnResize(columnindex, columnwidth: integer);
  begin
   if Assigned(FOnBeginColumnResize) then FOnBeginColumnResize(Self,columnIndex,columnWidth);
  end;

  procedure TWhiteListView.doColumnResize(columnindex, columnwidth: integer);
  begin
   if Assigned(FOnColumnResize) then FOnColumnResize(Self,columnIndex,columnWidth);
  end;

  procedure TWhiteListView.doEndColumnResize(columnindex, columnwidth: integer);
  begin
   if Assigned(FOnEndColumnResize) then FOnEndColumnResize(Self,columnIndex,columnWidth);
  end;

  procedure TWhiteListView.drawCustomHeaderBackground(aCanvas:TCanvas;aRect:TRect;aIndex,aState:integer);
  begin
  end;

  procedure TWhiteListView.drawItemBackground(aCanvas: TCanvas; aRect: TRect; v: TListItem);
  var idx:integer;
  begin
   if FMultiColorLines then
    begin
     with aCanvas do
      begin
       idx:=v.Index;
       if ((idx mod 2) = 0) then Brush.Color:=FLinesColor1 else Brush.Color:=FLinesColor2;
       Pen.Color:=Brush.Color;
       FillRect(aRect);
      end;
    end else with aCanvas do FillRect(aRect);
  end;
  
  procedure TWhiteListView.drawSelectedItem(aCanvas:TCanvas; aRect:TRect; v: TListItem);
  begin
   if not FSelectionMark then Exit; 
   with aCanvas do
    if v.Selected then
     begin
      Pen.Color:=TColor($00937544);
      Rectangle(aRect);
    end;
  end;
  
  function TWhiteListView.getColumnItemData(v: TListItem; aRect: TRect; row, index: Integer): WideString;
  begin
   Result:='';
   if Assigned(v) then
    if index=0 then Result:=v.Caption else if index-1<v.SubItems.Count then Result:=v.SubItems[index-1];
  end;

  procedure TWhiteListView.getColumnItemRect(v: TListItem; aRect:TRect; var r: TRect; row, index: Integer);
  begin
   r:=getItemRect(aRect,index);
   OffsetRect(r,-2,0);
  end;

  function TWhiteListView.GetColumnsFont(out v: TLOGFONT):Boolean;
  var hCurrentFont:THandle;
  begin
   Result:=False;
   if hwndHeader=0 then Exit;
   {$R-}
   hCurrentFont:=SendMessage(hwndHeader,WM_GETFONT,0,0);
   Result:=windows.GetObject(hCurrentFont,SizeOf(TLOGFONT),@v)>0;
   {$R+}
  end;
  
  function TWhiteListView.getHeaderData(c: integer): THDItem;
  var r:THDItem;
  begin
   Fillchar(r,SizeOf(THDItem),#0);
   if hwndHeader<>0 then Header_GetItem(hwndHeader,c,r);
   Result:=r;
  end;

  function TWhiteListView.GetHeaderHeight: integer;
  var r:TRect;
  begin
   if hwndHeader=0 then hwndHeader:=SendMessage(Handle,LVM_GETHEADER,0,0);
   if GetWindowRect(hwndHeader,r) then FHeaderHeight:=r.Bottom-r.top;
   Result:=FHeaderHeight;
  end;

  function TWhiteListView.getItemRect(aRect:TRect; index: integer): TRect;
  var
   i,gap:integer;
   r:TRect;
  begin
   gap:=aRect.Left;
   r:=aRect;
   for i:=0 to index-1 do gap:=gap+Column[i].Width;
   r.Left:=gap+2;
   r.Right:=r.Left+Column[index].Width-2;

   Result:=r;
  end;

  function TWhiteListView.getItemRows(v: TListItem): integer;
  begin
   Result:=1;
  end;

  function TWhiteListView.getRH: Integer;
  begin
   Result:=self.smallImages.Height;
  end;
  
  {procedure TWhiteListView.IntCustomDraw(Sender: TCustomListView; const aRect: TRect; var DefaultDraw: Boolean);
  var
   r:TRect;
   i:integer;
   hdm:THDITEM;
  begin
   hdm.mask:=HDI_FORMAT;
   for i:=0 to Columns.count-1 do
    begin
     hdm.fmt:=0;
     Header_GetItem(hwndHeader,i,hdm);
     if (hdm.fmt and HDF_OWNERDRAW)<>HDF_OWNERDRAW then Continue;
     hdm.fmt:=hdm.fmt or HDF_OWNERDRAW;
     Header_SetItem(hwndHeader,i,hdm);
    end;
   GetWindowRect(hwndHeader,r);
   if (r.bottom-r.top)<>FHeaderHeight then
    SetWindowPos(hwndHeader,0,0,0,r.right-r.left,FHeaderHeight,SWP_NOZORDER or SWP_NOMOVE);
  end;}

  procedure TWhiteListView.IntCustomDrawItem(Sender: TCustomListView;Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
  var r,ic:TRect;
  begin
   if Locked then Exit;
   DefaultDraw:=False;
   r:=Item.DisplayRect(drSelectBounds);
   ic:=Item.DisplayRect(drIcon);
   with TWhiteListView(Sender).Canvas do
    begin
     drawItemBackground(TListView(Sender).Canvas,r,Item);
     if item.Selected then drawSelectedItem(TListView(Sender).Canvas,r,Item);

     //SetTextColor(Handle,Font.Color);
     SetBkColor(Handle,ColorToRGB(Brush.Color));
     SetBkMode(TListView(Sender).Canvas.Handle,TRANSPARENT);

     drawCustomListItem(TListView(Sender).Canvas,State,r,Item);
    end;
  
  end;
  
  procedure TWhiteListView.IntMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  var
   pt:TPoint;
   li:TLIstItem;
   lvHitInfo:TLVHitTestInfo;
   _hint:string;
  begin
   pt:=ScreenToClient(Mouse.CursorPos);
   li:=GetItemAt(pt.x,pt.y);
   if li=nil then //over a sub item?
    begin
     FillChar(lvHitInfo,SizeOf(lvHitInfo),0);
     lvHitInfo.pt:=pt;
     if (-1<>Perform(LVM_SUBITEMHITTEST,0,LParam(@lvHitInfo))) and Assigned(@lvHitInfo) then //over a sub item!
      if (lvHitInfo.iItem>0) and (lvHitInfo.iSubItem>0) and ((lvHitInfo.iSubItem-1)>0) then
      begin
       _hint:=Format('Name: %s, %s : %s',[Items[lvHitInfo.iItem].Caption,Columns[lvHitInfo.iSubItem].Caption,Items[lvHitInfo.iItem].SubItems[-1 + lvHitInfo.iSubItem]]);
       if _hint<>hint then
        begin
         Hint:=_hint;
         Application.ActivateHint(Mouse.CursorPos); //activate hint
        end;
     end;
    end;
  end;
  
  procedure TWhiteListView.newHeaderWndProc(var Message: TMessage);
  var
   lpnmcd:PNMTTCustomDraw;
   nCanvas:TCanvas;
   r:TRect;
   cIndex,cState:integer;
   cCaption:WideString;
   f:boolean;
   dwFormat:DWORD;
  begin
   f:=true;
   {$R-}
   case message.Msg of
   {WM_NCCALCSIZE:begin
                  if BOOL(message.WParam)=true then
                   begin
                    if Assigned(PNCCalcSizeParams(message.LParam)) then
                     begin
                      //PNCCalcSizeParams(message.LParam)^.rgrc[0].Top:=PNCCalcSizeParams(message.LParam)^.rgrc[0].Top+FHeaderHeight;
                     end;
                    message.Result:=WVR_ALIGNBOTTOM or WVR_VALIDRECTS; //oldWndProc(message);
                   end else oldWndProc(message);
                 end;}
   //WM_NCPAINT:WMNCPaint(message);
   WM_NOTIFY:begin
              lpnmcd:=PNMTTCustomDraw(message.LParam);
              if (lpnmcd^.nmcd.hdr.code=NM_CUSTOMDRAW) and (lpnmcd^.nmcd.hdr.hwndFrom=GetDlgItem(Handle,0)) then
               begin
                case lpnmcd^.nmcd.dwDrawStage of
                CDDS_PREPAINT:begin
                               message.Result:=CDRF_NOTIFYITEMDRAW or CDRF_SKIPDEFAULT;
                               GetWindowRect(hwndHeader,r);
                               if (r.bottom-r.top)<>FHeaderHeight then
                                SetWindowPos(hwndHeader,0,0,0,r.right-r.left,FHeaderHeight,SWP_NOZORDER or SWP_NOMOVE);
                               f:=false;
                              end;
                CDDS_ITEMPREPAINT:begin
                                   nCanvas:=TCanvas.Create;
                                   nCanvas.Handle:=lpnmcd^.nmcd.hdc;
                                   nCanvas.Lock; 
  
                                   nCanvas.Font.Handle:=SendMessage(hwndHeader,WM_GETFONT,0,0);
                                   nCanvas.Font.Color:=FHDFontColor;
                                   nCanvas.Brush.Color:=Color;
  
                                   r:=lpnmcd^.nmcd.rc;
                                   cIndex:=lpnmcd^.nmcd.dwItemSpec;
                                   cState:=lpnmcd^.nmcd.uItemState;

                                   cCaption:=Self.Column[cIndex].Caption;
                                   SelectObject(nCanvas.Handle,nCanvas.Font.Handle);
                                   f:=false;

                                   nCanvas.FillRect(r);
                                   drawCustomHeaderBackground(nCanvas,r,cIndex,cState);
                                   nCanvas.Brush.Color:=Color;
                                   nCanvas.Font.Color:=FHDFontColor;
                                   r:=CustomHeaderRectAdjustment(lpnmcd^.nmcd.rc,cIndex);
                                   dwFormat:=CustomHeaderTextAlignment(r,cIndex);
                                   {$IFDEF WIN95UNICODE}safeDrawTextExW(nCanvas.Handle,PWideChar(cCaption),Length(cCaption),r,dwFormat,nil){$ELSE}DrawTextExW(nCanvas.Handle,PWideChar(cCaption),Length(cCaption),r,dwFormat,nil){$ENDIF};

                                   nCanvas.Unlock;
                                   //nCanvas.Handle:=0;
                                   //nCanvas.Free;
                                   DeleteObject(nCanvas.Font.Handle);
                                   message.Result:=CDRF_SKIPDEFAULT; //message.Result:=CDRF_NEWFONT{ or CDRF_SKIPDEFAULT};
                                  end;
                end;
               end else
                case TWMNotify(message).NMHdr^.code of
                 HDN_ENDTRACKW:begin
                                if not Assigned(FOnEndColumnResize) then message.Result:=windows.CallWindowProc(oldHeaderWndProc,hwndHeader,message.Msg,message.WParam,message.LParam)
                                 else doEndColumnResize(_FindColumnIndex(TWMNotify(message).NMHdr),_FindColumnWidth(TWMNotify(message).NMHdr));
                               end;
                 HDN_BEGINTRACKW:begin message.Result:=windows.CallWindowProc(oldHeaderWndProc,hwndHeader,message.Msg,message.WParam,message.LParam);doBeginColumnResize(_FindColumnIndex(TWMNotify(message).NMHdr),_FindColumnWidth(TWMNotify(message).NMHdr));end;
                 HDN_TRACKW:begin message.Result:=windows.CallWindowProc(oldHeaderWndProc,hwndHeader,message.Msg,message.WParam,message.LParam);doColumnResize(_FindColumnIndex(TWMNotify(message).NMHdr),_FindColumnWidth(TWMNotify(message).NMHdr));end;
                 else message.Result:=windows.CallWindowProc(oldHeaderWndProc,hwndHeader,message.Msg,message.WParam,message.LParam);
                end;
             end;
   WM_DESTROY:begin
               message.Result:=windows.CallWindowProc(oldHeaderWndProc,hwndHeader,message.Msg,message.WParam,message.LParam);
               hwndHeader:=0;
               oldHeaderWndProc:=nil;
               Exit;
              end;
   end;
   if f then message.Result:=windows.CallWindowProc(oldHeaderWndProc,hwndHeader,message.Msg,message.WParam,message.LParam);
   {$R+}
  end;

  procedure TWhiteListView.postCreate;
  begin
  end;

  procedure TWhiteListView.preDestroy;
  begin
  end;

  procedure TWhiteListView.predrawCustomColumnItem(aCanvas: TCanvas; aState: TCustomDrawState; aRect: TRect; v: TListItem; index: integer);
  begin
  end;

  function TWhiteListView.selectItemFont(aCanvas:TCanvas; aState:TCustomDrawState; aRect:TRect; v:TListItem; row,index:integer):THandle;
  var logRec:TLOGFONT;
  begin
   GetObject(aCanvas.Font.Handle,SizeOf(LogRec),@LogRec);
   logRec.lfQuality:=CLEARTYPE_QUALITY;
   logRec.lfOutPrecision:=OUT_TT_PRECIS;
   Result:=CreateFontIndirect(logRec);
   
   SetTextColor(aCanvas.Handle,FItemsFont.Color);
  end;

  procedure TWhiteListView.SetColumnsFont(v: TLOGFONT);
  begin
   if hHeaderFont<>0 then DeleteObject(hHeaderFont);
   if hwndHeader=0 then Exit;
   {$R-}
   hHeaderFont:=CreateFontIndirect(v);
   SelectObject(hwndHeader,hHeaderFont);
   SendMessage(hwndHeader,WM_SETFONT,hHeaderFont,1);
   {$R+}
  end;

  procedure TWhiteListView.SetFilters(const Value: Boolean);
  begin
   FFilters:=Value;
   case FFilters of
   true:SetWindowLong(hwndHeader,GWL_STYLE,GetWindowLong(hwndHeader,GWL_STYLE) or HDS_FILTERBAR);
   false:SetWindowLong(hwndHeader,GWL_STYLE,GetWindowLong(hwndHeader,GWL_STYLE) and not HDS_FILTERBAR);
   end;
  end;

  procedure TWhiteListView.SetHeaderHeight(const Value: integer);
  begin
   FHeaderHeight:=Value;
   InvalidateRect(Handle,nil,True);
  end;

  procedure TWhiteListView.setRH(const Value: Integer);
  begin
   self.smallImages.Height:=Value;
  end;

 (* procedure TWhiteListView.WMNCPaint(var Message: TMessage);
  var
   _hdc:HDC;
   rc,rw:TRect;
  begin
   Message.Result:=0; //0 - is proceses

   { DC := GetWindowDC(Handle);
    try
      Windows.GetClientRect(Handle, RC);
      GetWindowRect(Handle, RW);
      MapWindowPoints(0, Handle, RW, 2);
      OffsetRect(RC, -RW.Left, -RW.Top);
      ExcludeClipRect(DC, RC.Left, RC.Top, RC.Right, RC.Bottom);
      // Draw borders in non-client area
      SaveRW := RW;
      InflateRect(RC, BorderWidth, BorderWidth);
      RW := RC;
      with RW do
      begin
        WinStyle := GetWindowLong(Handle, GWL_STYLE);
        if (WinStyle and WS_VSCROLL) <> 0 then Inc(Right, GetSystemMetrics(SM_CYVSCROLL));
        if (WinStyle and WS_HSCROLL) <> 0 then Inc(Bottom, GetSystemMetrics(SM_CXHSCROLL));
      end;
      if BevelKind <> bkNone then
      begin
        EdgeSize := 0;
        if BevelInner <> bvNone then Inc(EdgeSize, BevelWidth);
        if BevelOuter <> bvNone then Inc(EdgeSize, BevelWidth);
        with RW do
        begin
          if beLeft in BevelEdges then Dec(Left, EdgeSize);
          if beTop in BevelEdges then Dec(Top, EdgeSize);
          if beRight in BevelEdges then Inc(Right, EdgeSize);
          if beBottom in BevelEdges then Inc(Bottom, EdgeSize);
        end;
        DrawEdge(DC, RW, InnerStyles[BevelInner] or OuterStyles[BevelOuter],
          Byte(BevelEdges) or EdgeStyles[BevelKind] or Ctl3DStyles[Ctl3D] or BF_ADJUST);
      end;
      IntersectClipRect(DC, RW.Left, RW.Top, RW.Right, RW.Bottom);
      RW := SaveRW;
      // Erase parts not drawn
      if Message.WParam = 1 then // Redraw entire NC area
        OffsetRect(RW, -RW.Left, -RW.Top)
      else
      begin
        GetRgnBox(Message.WParam, RC);
        MapWindowPoints(0, Handle, RC, 2);
        IntersectRect(RW, RW, RC);
        OffsetRect(RW, -SaveRW.Left, -SaveRW.Top);
      end;
      Windows.FillRect(DC, RW, Brush.Handle);
    finally
      ReleaseDC(Handle, DC);
    end;    }



              {begin
               _hdc:=Windows.GetWindowDC(Handle);

               windows.GetClientRect(Handle,rc);
               windows.GetWindowRect(Handle,rw);
               windows.MapWindowPoints(0,Handle,rw,2);
               windows.OffsetRect(rc,-rw.Left,-rw.Top);
               //windows.ExcludeClipRect(_hdc,rc.Left,rc.Top,rc.Right,rc.Bottom);
               windows.OffsetRect(rw,-rw.Left,-rw.Top);

               nCanvas:=TCanvas.Create;
               nCanvas.Handle:=_hdc;
               nCanvas.Lock;

               nCanvas.Font.Handle:=SendMessage(hwndHeader,WM_GETFONT,0,0);
               nCanvas.Font.Color:=FHDFontColor;

               nCanvas.Brush.Color:=clRed;
               nCanvas.Pen.Color:=clRed;

               nCanvas.FrameRect(rw);

               nCanvas.Unlock;
               DeleteObject(nCanvas.Font.Handle);
               ReleaseDC(Handle,_hdc);

               Message.Result:=0;
               f:=False;
              end;     }

  end; *)

  function TWhiteListView._findColumnIndex(pHeader: pNMHdr): Integer;
  begin
   Result:=-1;
   if Assigned(pHeader) then Result:=PHDNotifyW(pHeader)^.Item;
  end;

  function TWhiteListView._findColumnWidth(pHeader: pNMHdr): integer;
  begin
   Result:=-1;
   if Assigned(PHDNotifyW(pHeader)^.pItem) and ((PHDNotifyW(pHeader)^.pItem^.mask and HDI_WIDTH)<>0) then Result:=PHDNotifyW(pHeader)^.pItem^.cxy;
  end;

{$ENDREGION}

end.
