unit main;

interface

{$IFOPT D-}{$WEAKLINKRTTI ON}{$ENDIF}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

uses Winapi.Windows, Winapi.Messages,
     System.SysUtils, System.Classes, System.Types, Vcl.Forms,
     Vcl.ComCtrls, Vcl.Controls, Vcl.StdCtrls, Vcl.ImgList,
     Vcl.XPMan, Vcl.CheckLst, Vcl.Graphics, System.Rtti,
     System.Bindings.Outputs, Vcl.Bind.Editors, Data.Bind.EngExt,
     Vcl.Bind.DBEngExt, Data.Bind.Components, Search;

{$SetPEFlags IMAGE_FILE_EXECUTABLE_IMAGE}
{$SetPEFlags IMAGE_FILE_AGGRESIVE_WS_TRIM}

type

  TmainFrm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    Label2: TLabel;
    ComboBox2: TComboBox;
    CheckBox1: TCheckBox;
    Button3: TButton;
    IL: TImageList;
    XPManifest1: TXPManifest;
    GroupBox1: TGroupBox;
    ComboBox3: TComboBox;
    Label3: TLabel;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    ComboBox4: TComboBox;
    GroupBox4: TGroupBox;
    Edit1: TEdit;
    ComboBox5: TComboBox;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    Label6: TLabel;
    Label7: TLabel;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    Edit2: TEdit;
    ComboBox6: TComboBox;
    BindingsList1: TBindingsList;
    LinkControlToProperty1: TLinkControlToProperty;
    LinkControlToProperty2: TLinkControlToProperty;
    LinkControlToProperty3: TLinkControlToProperty;
    LinkControlToProperty4: TLinkControlToProperty;
    Label4: TLabel;
    CheckBox15: TCheckBox;
    procedure FormActivate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ComboBox4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
   procedure startSearchOperation(Sender:TObject);
   procedure endSearchOperation(Sender:TObject);
   procedure itemfound(Sender:TObject);
   procedure WMGetMinMaxInfo(var info:TWMGetMinMaxInfo);message WM_GETMINMAXINFO;
  public
   lv:TListView;
   operation:TSearchOperation;
  end;

var mainFrm: TmainFrm;

implementation

{$R *.dfm}

uses settings, utils, WinApi.ShLwApi, WinApi.ActiveX, WinApi.CommCtrl, wlistview2;

{ TmainFrm }

procedure TmainFrm.Button1Click(Sender: TObject);
var i,h:integer;
begin
 Button1.Enabled:=False;
 Screen.Cursor:=crHourGlass;
 Cursor:=crHourGlass;
 Button2.Enabled:=True;
 PageControl1.ActivePageIndex:=0;
 PageControl1.Enabled:=False;

 // create dynamicaly ListView for items
 if not Assigned(lv) then  // need some fixes
  begin
   lv:=TListView.Create(Self);
   lv.BoundsRect:=Rect(0,0,ClientWidth-16,400);
   lv.Top:=310;
   lv.Left:=8;
   lv.Height:=0;
   lv.Parent:=Self;
   lv.ViewStyle:=vsReport;
   lv.ShowColumnHeaders:=True;
   lv.ReadOnly:=True;
   lv.DoubleBuffered:=True;
   lv.GridLines:=False;
   lv.MultiSelect:=False;
   lv.Anchors:=[akLeft,akTop,akRight,akBottom];
   with lv.Columns do
    begin
     with add do begin caption:='#'; width:=20;end;
     with add do begin caption:='Path'; width:=420;end;
     with add do begin caption:='Modified'; width:=90;end;
    end;

   // resizing form and correcting position
   h:=Height;
   i:=h;
   while i<h+200 do
    begin
     inc(i,50);
     height:=i;
     sleepex(10,true);
     Application.ProcessMessages;
    end;
   Application.ProcessMessages;
  end else lv.Items.Clear;
 Position:=poDesktopCenter;

 startSearchOperation(Self);
end;

procedure TmainFrm.Button2Click(Sender: TObject);
begin
 if Assigned(operation) then operation.Terminate;
end;

procedure TmainFrm.Button3Click(Sender: TObject);
var pth:WideString;
begin
 pth:=ComboBox2.Text;
 if BrowseForFolder(Handle,'Select path to start searching',pth) then
  ComboBox2.ItemIndex:=ComboBox2.Items.Add(WideString(pth));
end;

procedure TmainFrm.ComboBox4Click(Sender: TObject);
begin
 DateTimePicker1.Enabled:=ComboBox4.ItemIndex>0;
 DateTimePicker2.Enabled:=ComboBox4.ItemIndex>0;
end;

procedure TmainFrm.endSearchOperation(Sender: TObject);
begin
 Application.ProcessMessages;

 PageControl1.Enabled:=True;
 Button2.Enabled:=False;
 Cursor:=crDefault;
 Screen.Cursor:=crDefault;
 Button1.Enabled:=True;
end;

procedure TmainFrm.FormActivate(Sender: TObject);
var
 pth:array[0..MAX_PATH] of WideChar;
 sz:DWORD;
begin
 OnActivate:=nil;

 if not ISAeroEnabled then // little cleanup
  begin
   GlassFrame.Enabled:=false;
   Label1.Font.Color:=clWindowText;
  end;

 // setup initial parameters

 ComboBox1.ItemIndex:=ComboBox1.Items.Add('*.*');
 SHAutoComplete(FindWindowEx(ComboBox2.Handle,0,nil,nil),(SHACF_FILESYSTEM or SHACF_FILESYS_ONLY));

 if ComboBox2.Items.Count=0 then
  begin
   ZeroMemory(@pth,SizeOf(pth));
   sz:=SizeOf(pth) div SizeOf(WCHAR);
   if GetCurrentDirectoryW(sz,@pth)>0 then ComboBox2.ItemIndex:=ComboBox2.Items.Add(WideString(pth));
  end;
 CheckBox1.Checked:=True;


end;

procedure TmainFrm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 FreeAndNil(lv);
 if Assigned(operation) then
  begin
   operation.Terminate;
   sleepex(100,true);
   FreeAndNil(operation);
  end;
end;

procedure TmainFrm.FormCreate(Sender: TObject);
begin
 CheckBox13.Checked:=False;
 CheckBox14.Checked:=False;

 lv:=nil;
 operation:=nil;
end;

procedure TmainFrm.itemfound(Sender: TObject);
var
 itm:TListItem;
 st:TSystemTime;
 location:TFileLocation;
begin
 if not Assigned(lv) then Exit;
 if not Assigned(Sender) then Exit;



 Application.ProcessMessages;

 itm:=lv.Items.Add;
 itm.Caption:=IntToStr(lv.Items.Count);
 itm.SubItems.Add(OleStrToString(PFileLocation(Sender)^.path));
 FileTimetoSystemTime(PFileLocation(Sender)^.data.ftLastWriteTime,st);
 itm.SubItems.Add(FormatDateTime('dd/mmm/yyyy',SystemTimeToDatetime(st))+' '+FormatDateTime('hh:nn:ss',SystemTimeToDatetime(st)));
 itm.Data:=Sender;
 //itm.ImageIndex:=

end;

procedure TmainFrm.RadioButton1Click(Sender: TObject);
begin
 if not Assigned(Sender) then Exit;
 if TRadioButton(Sender).Name='RadioButton1' then
  begin
   ComboBox2.Enabled:=TRadioButton(Sender).Checked;
   Button3.Enabled:=TRadioButton(Sender).Checked;
   CheckBox1.Enabled:=TRadioButton(Sender).Checked;
  end
 else
  begin
   ComboBox2.Enabled:=not TRadioButton(Sender).Checked;
   Button3.Enabled:=not TRadioButton(Sender).Checked;
   CheckBox1.Enabled:=not TRadioButton(Sender).Checked;
  end;
end;

procedure TmainFrm.startSearchOperation(Sender: TObject);
var
 p:TSearchParameters;
 st,et:TDateTime;
 ssz,esz:Int64;
begin
 if Assigned(operation) then
  begin
   operation.Terminate;
   sleepex(100,true);
   FreeAndNil(operation);
  end;

 // creating search query
 p.search(ComboBox2.Text,ComboBox1.Text);
 p.recursive:=CheckBox1.Checked;

 // File Attributes constraints



 // Date Constraints
 if DateTimePicker1.Enabled or DateTimePicker2.Enabled then
  begin

   //p.constraintTime(st,et);
  end;

 // Size Constraints
 if Checkbox1.Checked or CheckBox2.Checked then
  begin


   //p.constraintFileSize(ssz,esz);
  end;

 // Text in files
 if ComboBox3.Text<>'' then
  begin

   p.constraintFileContent(ComboBox3.Text,encASCII);
  end;

 operation:=TSearchOperation.Create(p,itemFound);
 operation.eos:=WinApi.Windows.CreateEvent(nil,true,false,nil);
 operation.Resume;
end;

procedure TmainFrm.WMGetMinMaxInfo(var info: TWMGetMinMaxInfo);
begin
 info.MinMaxInfo^.ptMinTrackSize:=Point(600,350);
end;

initialization
 CoInitialize(nil);
end.
