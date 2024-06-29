unit MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, dbf, SQLite3Conn, SQLDB, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, ActnList, Menus, DBGrids, Buttons,
  fpjson, jsonparser, jsonConf, openssl, opensslsockets, fphttpclient, DOM,
  XMLWrite, xmltextreader, simpleipc, LazFileUtils, LCLTranslator,
  RegExpr, httpprotocol, LCLType, process, dynlibs, fileutil, Translations,
  LResources;

const
  BASE_PATH = '/mnt/SDCARD';

type
  TEmuConfig = record
    Caption: String;
    Icon: String;
    System: String;
    EmuPath: String;
    RomPath: String;
    ImgPath: String;
    CachePath: String;
    Shortname: Boolean;
    UseSwap: Boolean;
    HideBios: Boolean;
    Gamelist: String;
    ExtList: String;
  end;

  PScrapeInfo = ^TScrapeInfo;
  TScrapeInfo = record
    System, Key, ImagePath, SearchStr, Gamelist: String;
    IsShortname, IsForce: Boolean;
  end;

  { TQueueThread }

  TQueueThread = class(TThread)
  private
    HttpClient: TFPHttpClient;
    Image: TImage;
    BasePath: String;
    IPCClient: TSimpleIPCClient;
    ScrapeList: TList;
  public
    constructor Create(CreateSuspended: boolean);
    destructor Destroy; override;
    procedure Execute; override;
    procedure SetBasePath(Path: String);
    procedure CancelScrape;
    procedure Put(ScrapeInfo: TScrapeInfo);
    function Get(var ScrapeInfo: TScrapeInfo): Boolean;
    procedure Scrape(ScrapeInfo: TScrapeInfo; IsArcade: Boolean);
//    procedure ScrapeYahoo(ScrapeInfo: TScrapeInfo);
    procedure WriteLog(Log: String);
  end;

  { TFormMain }

  TFormMain = class(TForm)
    acCancelScrape: TAction;
    acDelete: TAction;
    acRename: TAction;
    acRescrapeAll: TAction;
    acScrape: TAction;
    acScrapeMissing: TAction;
    acChangeImage: TAction;
    acOpenImagePos: TAction;
    acSaveEmuInfo: TAction;
    acBuildGamelist: TAction;
    acRefresh: TAction;
    acDetectBasePath: TAction;
    acOpenBasePath: TAction;
    acExit: TAction;
    acGenerateCache: TAction;
    acAbout: TAction;
    acAddRom: TAction;
    ActionList: TActionList;
    btGenerateCache: TButton;
    btGenerateGamelist: TButton;
    btOpen: TButton;
    btAutoDetect: TButton;
    btRefresh: TButton;
    btScrape: TButton;
    btSaveEmuInfo: TButton;
    C1: TMenuItem;
    cboEmulator: TComboBox;
    ckHideBios: TCheckBox;
    ckShortname: TCheckBox;
    ckUseSwap: TCheckBox;
    Delete1: TMenuItem;
    edBasePath: TEdit;
    edLabel: TEdit;
    edRomPath: TEdit;
    edImagePath: TEdit;
    edExtList: TEdit;
    edGamelist: TEdit;
    edIcon: TEdit;
    edSearch: TEdit;
    GroupBox1: TGroupBox;
    Image: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ListView: TListView;
    MainMenu: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    mnLangKor: TMenuItem;
    mnLangEng: TMenuItem;
    Separator4: TMenuItem;
    Separator3: TMenuItem;
    Separator2: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    Separator1: TMenuItem;
    mmLog: TMemo;
    N1: TMenuItem;
    NoImage: TImage;
    Panel1: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    pmScrape: TMenuItem;
    pmPopup: TPopupMenu;
    pmImage: TPopupMenu;
    Rename1: TMenuItem;
    RescrapeAll1: TMenuItem;
    Scrapemissing1: TMenuItem;
    SQLite3Connection: TSQLite3Connection;
    SQLite3Name: TSQLite3Connection;
    SQLQuery: TSQLQuery;
    SQLName: TSQLQuery;
    SQLTransaction: TSQLTransaction;
    SQLTransactionName: TSQLTransaction;
    procedure acAboutExecute(Sender: TObject);
    procedure acAddRomExecute(Sender: TObject);
    procedure acBuildGamelistExecute(Sender: TObject);
    procedure acCancelScrapeExecute(Sender: TObject);
    procedure acChangeImageExecute(Sender: TObject);
    procedure acDeleteExecute(Sender: TObject);
    procedure acDetectBasePathExecute(Sender: TObject);
    procedure acExitExecute(Sender: TObject);
    procedure acGenerateCacheExecute(Sender: TObject);
    procedure acOpenBasePathExecute(Sender: TObject);
    procedure acOpenImagePosExecute(Sender: TObject);
    procedure acRefreshExecute(Sender: TObject);
    procedure acRenameExecute(Sender: TObject);
    procedure acSaveEmuInfoExecute(Sender: TObject);
    procedure acScrapeExecute(Sender: TObject);
    procedure acScrapeMissingExecute(Sender: TObject);
    procedure btGenerateCacheClick(Sender: TObject);
    procedure btOpenClick(Sender: TObject);
    procedure cboEmulatorChange(Sender: TObject);
    procedure edSearchKeyPress(Sender: TObject; var Key: char);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
    procedure FormShow(Sender: TObject);
    procedure ListViewCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure ListViewEdited(Sender: TObject; Item: TListItem;
      var AValue: string);
    procedure ListViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure MenuItem15Click(Sender: TObject);
    procedure mnLangKorClick(Sender: TObject);
  private
    procedure AppIdle(Sender: TObject; var Done: Boolean);
  public
    IPCServer: TSimpleIPCServer;
    EmuConfig: TEmuConfig;
    QueueThread: TQueueThread;
    procedure IPCServerMessage(Sender: TObject);
    procedure LoadEmus(BasePath: String);
    procedure WriteLog(Log: String);
    function LoadEmuConfig(System: String): Boolean;
    function LoadEmuInfo(System: String): Boolean;
    function SaveEmuConfig(System: String): Boolean;
    procedure BuildCache;
    procedure GetEmuList;
    function RenameTitle(Key, Tobe: String): Boolean;
    function InsertCache(Filename: String): String;
    function UpdateCache(Key, Column, Value: String): Boolean;
    function DeleteCache(Key: String): Boolean;
    function GetFullTitle(Title, DefaultTitle: String): String;
    function UpdateRomName(Key, Value: String): Boolean;
    procedure ReadSettings;
    procedure WriteSettings;
  end;

var
  FormMain: TFormMain;
  SystemMap: TStringList;

resourcestring
  I18N_SCRAPESTARTED = ' 스크랩이 시작되었습니다';
  I18N_ROMFROM = '롬 한글정보 출처: 텐타클팀(http://cafe.naver.com/raspigamer)';
  I18N_FILENOTFOUND = '파일을 찾을 수 없습니다';
  I18N_DIRNOTFOUND = '디렉터리를 찾을 수 없습니다';
  I18N_CANCELEDSCRAPE = '스크랩이 취소되었습니다';
  I18N_GENCACHE = '캐시를 생성하고 있습니다...';
  I18N_ERROROCCURED = '오류가 발생하였습니다';
  I18N_FILEEXISTS = '파일이 존재합니다';
  I18N_NOSELEMUL = '선택된 에뮬레이터가 없습니다';
  I18N_DONESCRAPE = '스크랩이 완료되었습니다';
  I18N_ROMNOTSELECTED = '롬을 먼저 선택해주세요';
  I18N_SAVED = '저장되었습니다';
  I18N_CREATED = '생성되었습니다';
  I18N_PROCESSING = '처리중입니다';
  I18N_DELETED = '삭제되었습니다';
  I18N_CONFIRM = '확인';
  I18N_ADDED = '추가되었습니다';
  I18N_RECACHECONFIRM = '캐시 파일을 재생성합니다. 계속 하시겠습니까?';
  I18N_DELETECONFIRM = '롬 파일을 삭제합니다. 계속 하시겠습니까?';
  I18N_GAMELISTCONFIRM = '캐시로부터 gamelist.xml 파일을 새로 생성합니다. 계속 하시겠습니까?';

implementation

{$R *.lfm}

uses
  IniFiles;

var
  CriticalSection: TRTLCriticalSection;

function Translate(const Language: String): boolean;
var
  Res: TResourceStream;
  PoStringStream: TStringStream;
  PoFile: TPOFile;
  LocalTranslator: TPOTranslator;
  i: Integer;
begin
  Res := TResourceStream.Create(HInstance, 'I18N.' + Language, RT_RCDATA);
  PoStringStream := TStringStream.Create('');
  try
    Res.SaveToStream(PoStringStream)
  finally
    Res.Free;
  end;

  PoFile := TPOFile.Create(False);
  try
    PoFile.ReadPOText(PoStringStream.DataString);
    Result := TranslateResourceStrings(PoFile);

    LocalTranslator := TPOTranslator.Create(PoFile);

    if Assigned(LRSTranslator) then
      LRSTranslator.Free;
    LRSTranslator := LocalTranslator;

    for i := 0 to Pred(Screen.CustomFormCount) do
      LocalTranslator.UpdateTranslation(Screen.CustomForms[i]);
    for i := 0 to Pred(Screen.DataModuleCount) do
      LocalTranslator.UpdateTranslation(Screen.DataModules[i]);
  finally
    if Assigned(PoStringStream) then
      PoStringStream.Free;
  end;
end;

function SaveImage(Image: TImage; var ImagePath: String): Boolean;
begin
  if Image.Picture.Graphic.Classname = 'TPortableNetworkGraphic' then
  begin
    if ExtractFileExt(ImagePath) <> '.png' then
      ImagePath := ImagePath + '.png'
  end else if Image.Picture.Graphic.Classname = 'TJpegImage' then
  begin
    if ExtractFileExt(ImagePath) <> '.jpg' then
      ImagePath := ImagePath + '.jpg'
  end else begin
    Result := False;
    exit;
  end;

  if FileExists(ImagePath) then
    SysUtils.DeleteFile(ImagePath);
  Image.Picture.SaveToFile(ImagePath);

  Result := True;
end;

function Win2Lin(BasePath, WinPath: String): String;
begin
{$IFDEF Linux}
  Result := StringReplace(WinPath, BasePath, BASE_PATH, [rfReplaceAll]);
{$ELSE}
  Result := StringReplace(
    StringReplace(WinPath, BasePath, BASE_PATH, []), '\', '/', [rfReplaceAll]);
{$ENDIF}
end;

function Lin2Win(BasePath, LinPath: String): String;
begin
{$IFDEF Linux}
  Result := ExpandFileName(StringReplace(LinPath, BASE_PATH, BasePath, [rfReplaceAll]));
{$ELSE}
  Result := ExpandFileName(StringReplace(
    StringReplace(LinPath, BASE_PATH, BasePath, []), '/', '\', [rfReplaceAll]));
{$ENDIF}
end;
{
function UpdateGamelist(BasePath: String; Info: TScrapeInfo): Boolean;
var
  Xml: TXMLDocument;
  RootNode, Node, ChildNode: TDOMNode;
  i: Integer;
begin
  Result := False;
  if FileExists(Info.Gamelist) then
    ReadXMLFile(Xml, Info.Gamelist)
  else
    Xml := TXMLDocument.Create;

  try
    RootNode := Xml.FindNode('gameList');
    if RootNode = nil then
      exit;
    for i:= 0 to RootNode.GetChildNodes.Count-1 do
    begin
      Node := RootNode.GetChildNodes.Item[i];
      ChildNode := Node.FindNode('path');
      if ChildNode.TextContent = UnicodeString(Info.Key) then
      begin
        ChildNode := Node.FindNode('image');
        if ChildNode = nil then
          ChildNode := Node.AppendChild(Xml.CreateElement('image'));
        ChildNode.TextContent := UnicodeString(Win2Lin(BasePath, Info.ImagePath, False));
        Result := True;
        break;
      end;
    end;
  finally
    EnterCriticalSection(CriticalSection);
    try
      if Result then
        WriteXMLFile(Xml, Info.Gamelist);
    finally
      LeaveCriticalSection(CriticalSection);
    end;
    Xml.Free;
  end;
end;
}
{ TQueueThread }

constructor TQueueThread.Create(CreateSuspended : boolean);
begin
  inherited Create(CreateSuspended);
  Image := TImage.Create(nil);
  HttpClient := TFPHTTPClient.Create(nil);

  ScrapeList := TList.Create;
  IPCClient := TSimpleIPCClient.Create(nil);
  IPCClient.ServerID := 'WriteLog';
end;

destructor TQueueThread.Destroy;
var
  i: Integer;
begin
  for i:=0 to ScrapeList.Count-1 do
    Dispose(PScrapeInfo(ScrapeList.Items[i]));
  ScrapeList.Free;
  IPCClient.Free;
  HttpClient.Free;
  Image.Free;
  inherited Destroy;
end;

procedure TQueueThread.Execute;
var
  ScrapeInfo: TScrapeInfo;
begin
  ScrapeInfo.System := '';
  ScrapeInfo.SearchStr := '';
  ScrapeInfo.Key := '';
  ScrapeInfo.ImagePath := '';
  ScrapeInfo.IsShortname := False;
  ScrapeInfo.IsForce := False;
  ScrapeInfo.Gamelist := '';

  while not Terminated do
  begin
    while Get(ScrapeInfo) do
    begin
      WriteLog(ScrapeInfo.SearchStr + I18N_SCRAPESTARTED);
      if ScrapeInfo.IsShortname then
        Scrape(ScrapeInfo, True)
      else
        Scrape(ScrapeInfo, False);
    end;
    Sleep(1000);
  end;
end;

procedure TQueueThread.SetBasePath(Path: String);
begin
  Self.BasePath := Path;
end;

procedure TQueueThread.CancelScrape;
begin
  EnterCriticalSection(CriticalSection);
  WriteLog(I18N_CANCELEDSCRAPE + ' - ' + IntToStr(ScrapeList.Count));
  try
    ScrapeList.Clear;
  finally
    LeaveCriticalSection(CriticalSection);
  end;

end;

procedure TQueueThread.Put(ScrapeInfo: TScrapeInfo);
var
  Info: PScrapeInfo;
begin
  EnterCriticalSection(CriticalSection);
  try
    New(Info);
    Info^ := ScrapeInfo;
    ScrapeList.Add(Info);
  finally
    LeaveCriticalSection(CriticalSection);
  end;
end;

function TQueueThread.Get(var ScrapeInfo: TScrapeInfo): Boolean;
begin
  EnterCriticalSection(CriticalSection);
  try
    if ScrapeList.Count > 0 then
    begin
      ScrapeInfo := PScrapeInfo(ScrapeList[0])^;
      ScrapeList.Delete(0);
      Result := True;
    end else
      Result := False;
  finally
    LeaveCriticalSection(CriticalSection);
  end;
end;

procedure TQueueThread.Scrape(ScrapeInfo: TScrapeInfo; IsArcade: Boolean);
var
  JsonStr, ImageUrl: String;
  JData : TJSONData;
  Stream: TStream;
  SysStr: String;
  Contents: String;
  RegEx: TRegExpr;
  function GetText(Title: String): String;
  var
    i: Integer;
  begin
    for i:=1 to Length(Title) do
      if Title[i] in ['(', '['] then
      begin
        Result := Copy(Title, 1, i-1);
        exit;
      end;
    Result := Title;
  end;
begin
  if not DirectoryExists(ExtractFileDir(ScrapeInfo.ImagePath)) then
    MkDir(ExtractFileDir(ScrapeInfo.ImagePath));
  if FileExists(ScrapeInfo.ImagePath) and not ScrapeInfo.IsForce then
  begin
    WriteLog(ScrapeInfo.ImagePath + ' - ' + I18N_FILEEXISTS);
    exit;
  end;

  Stream := TMemoryStream.Create;

  try
    try
      if IsArcade then
      begin
        with HttpClient do
        begin
          JsonStr := Get('http://adb.arcadeitalia.net/service_scraper.php?ajax=query_mame&game_name=' + ScrapeInfo.SearchStr);

          JData := GetJSON(JsonStr);

          ImageUrl := TJsonObject(JData).FindPath('result[0].url_image_ingame').AsString;
          Get(ImageUrl, Stream);
        end;
      end else
      begin
        SysStr := ScrapeInfo.System;
        if SystemMap.Values[ScrapeInfo.System] <> '' then
          SysStr := SystemMap.Values[ScrapeInfo.System];
        try
          Contents := HttpClient.Get('https://images.search.yahoo.com/search/images?p=' +
          HTTPEncode(StringReplace('screenshot+gamefabrique+'+GetText(ScrapeInfo.SearchStr)+'+'+SysStr, ' ', '+', [rfReplaceAll])));
        except
          on E :Exception do
          begin
            WriteLog(HttpClient.ResponseStatusText + ' - ' + E.Message);
            exit;
          end;
        end;

        RegEx := TRegExpr.Create('img data-src=''(https://tse\d\.mm\.bing\.net.*?)'' alt=');

        try
          if RegEx.Exec(Contents) then
          begin
            ImageUrl := RegEx.Match[1];
            HttpClient.Get(ImageUrl, Stream);
          end;
        finally
          RegEx.Free;
        end;
      end;

      Stream.Seek(0, soFromBeginning);
      Image.Picture.LoadFromStream(Stream);

      if not SaveImage(Image, ScrapeInfo.ImagePath) then
      begin
        WriteLog('Scraping ' + ScrapeInfo.System + ' - ' + Image.Picture.Graphic.Classname + '--> File format error');
        exit;
      end;

      WriteLog(ScrapeInfo.SearchStr + ' - ' + I18N_DONESCRAPE);
      WriteLog('@' + ScrapeInfo.ImagePath + '|' + ScrapeInfo.System + '|' + ScrapeInfo.Key);
    except
      on E :Exception do
      WriteLog(ScrapeInfo.SearchStr + I18N_ERROROCCURED + ' - ' + E.Message);
    end;

  finally
    Stream.Free;
  end;
end;

procedure TQueueThread.WriteLog(Log: String);
begin
  if not IPCClient.ServerRunning then
     exit;
  IPCClient.Active := True;
  try
    IPCClient.SendStringMessage(Log);
  finally
    IPCClient.Active := False;
  end;
end;

{ TFormMain }

procedure TFormMain.btOpenClick(Sender: TObject);
begin

end;

procedure TFormMain.acScrapeExecute(Sender: TObject);
var
  i: Integer;
  Filename: String;
  ScrapeInfo: TScrapeInfo;
begin
  if ListView.Selected = nil then
  begin
    ShowMessage(I18N_ROMNOTSELECTED);
    exit;
  end;

  ScrapeInfo.Gamelist := EmuConfig.Gamelist;
  ScrapeInfo.System := EmuConfig.System;
  ScrapeInfo.IsShortname := (EmuConfig.Shortname)and(edSearch.Text = '');
  ScrapeInfo.IsForce := True;
  QueueThread.SetBasePath(edBasePath.Text);

  for i:= 0 to ListView.Items.Count-1 do
  begin
    if ListView.Items[i].Selected then
    begin
      if (edSearch.Text <> '') and (ListView.SelCount=1) then
        ScrapeInfo.SearchStr := edSearch.Text
      else
        ScrapeInfo.SearchStr := ListView.Items[i].SubItems[1];
      ScrapeInfo.Key := ListView.Items[i].SubItems[1];
      Filename := ExtractFilename(Lin2Win(edBasePath.Text, ListView.Items[i].SubItems[2]));
      ScrapeInfo.ImagePath := EmuConfig.ImgPath + DirectorySeparator + ExtractFileNameWithoutExt(Filename);

      QueueThread.Put(ScrapeInfo);
    end;
  end;
end;

procedure TFormMain.acScrapeMissingExecute(Sender: TObject);
var
  ScrapeInfo: TScrapeInfo;
  Filename: String;
  i: Integer;
begin
  ScrapeInfo.Gamelist := EmuConfig.Gamelist;
  ScrapeInfo.System := EmuConfig.System;
  ScrapeInfo.IsShortname := EmuConfig.Shortname;
  ScrapeInfo.IsForce := True;
  QueueThread.SetBasePath(edBasePath.Text);

  for i:=0 to ListView.Items.Count-1 do
  begin
    if FileExists(Lin2Win(edBasePath.Text, ListView.Items[i].SubItems[0])) then
      continue;
    ScrapeInfo.SearchStr := ListView.Items[i].SubItems[1];
    ScrapeInfo.Key := ListView.Items[i].SubItems[1];
    Filename := ExtractFilename(Lin2Win(edBasePath.Text, ListView.Items[i].SubItems[2]));
    ScrapeInfo.ImagePath := EmuConfig.ImgPath + DirectorySeparator + ExtractFileNameWithoutExt(Filename);
    QueueThread.Put(ScrapeInfo);
  end;
end;

procedure TFormMain.btGenerateCacheClick(Sender: TObject);
begin

end;

procedure TFormMain.acRenameExecute(Sender: TObject);
begin
  if ListView.Selected = nil then
    exit;
  ListView.Selected.EditCaption;
end;

procedure TFormMain.acSaveEmuInfoExecute(Sender: TObject);
var
  EmuPath: String;
  JConfig: TJSONConfig;
begin
  if cboEmulator.Items.Count = 0 then
    exit;

  EmuPath := edBasePath.Text + DirectorySeparator + 'Emus' + DirectorySeparator + EmuConfig.System + DirectorySeparator + 'config.json';

  if not FileExists(EmuPath) then
  begin
    WriteLog(EmuPath + ' - ' + I18N_FILENOTFOUND);
    exit;
  end;
  JConfig := TJSONConfig.Create(nil);
  try
    try
      JConfig.Formatted := True;
      JConfig.Filename := EmuPath;

      JConfig.SetValue('/label', edLabel.Text);
      JConfig.SetValue('/icon', edIcon.Text);
      JConfig.SetValue('/rompath' , edRomPath.Text);
      if edGamelist.Text <> '' then
        JConfig.SetValue('/gamelist', edGamelist.Text)
      else
        JConfig.DeleteValue('/gamelist');
      JConfig.SetValue('/imgpath' , edImagePath.Text);

      JConfig.SetValue('/shortname', Ord(ckShortname.Checked));
      JConfig.SetValue('/hidebios', Ord(ckHideBios.Checked));
      JConfig.SetValue('/useswap', Ord(ckUseSwap.Checked));
      JConfig.SetValue('/extlist', edExtList.Text);
    except
      on E: Exception do
        WriteLog(EmuConfig.System + ' - config.json : ' + E.Message);
    end;
  finally
    WriteLog(I18N_SAVED + ' - ' + EmuPath);
    JConfig.Free;
  end;
end;

procedure TFormMain.acCancelScrapeExecute(Sender: TObject);
begin
  QueueThread.CancelScrape;
end;

procedure TFormMain.acBuildGamelistExecute(Sender: TObject);
var
  Xml: TXMLDocument;
  RootNode, Node, ChildNode: TDOMNode;
begin
  if cboEmulator.Items.Count = 0 then
  begin
    ShowMessage(I18N_NOSELEMUL);
    exit;
  end;

  if not FileExists(EmuConfig.CachePath) then
    btGenerateCache.Click;

  if Application.MessageBox(PChar(I18N_GAMELISTCONFIRM),
    PChar(I18N_CONFIRM), MB_ICONQUESTION + MB_YESNO) <> IDYES then
    exit;

  SQLite3Connection.DatabaseName := EmuConfig.CachePath;

  if not SQLite3Connection.Connected then
    SQLite3Connection.Connected := True;

  Xml := TXMLDocument.Create;

  try
    SQLQuery.SQL.Text := Format('SELECT disp, path, imgpath, pinyin, opinyin FROM %s_roms', [EmuConfig.System]);
    try
      SQLQuery.Active := True;
    except
      on E :Exception do
      begin
        WriteLog(I18N_ERROROCCURED + ' - ' + EmuConfig.System + '_roms - ' + E.Message);
        exit;
      end;
    end;

    RootNode := Xml.CreateElement('gameList');
    Xml.AppendChild(RootNode);

    SQLQuery.First;

    while not SQLQuery.EOF do
    begin
      Node := Xml.CreateElement('game');
      RootNode.AppendChild(Node);

      ChildNode := Xml.CreateElement('name');
      ChildNode.TextContent := SQLQuery.FieldByName('disp').AsUnicodeString;
      Node.AppendChild(ChildNode);

      ChildNode := Xml.CreateElement('path');
      ChildNode.TextContent := UnicodeString(StringReplace(SQLQuery.FieldByName('path').AsString, EmuConfig.EmuPath + '/', '', []));
      Node.AppendChild(ChildNode);

      ChildNode := Xml.CreateElement('image');
      ChildNode.TextContent := UnicodeString(StringReplace(SQLQuery.FieldByName('imgpath').AsString, EmuConfig.EmuPath + '/', '', []));
      Node.AppendChild(ChildNode);

      SQLQuery.Next;
    end;

    if (Trim(EmuConfig.Gamelist) = '') or (Trim(edGamelist.Text) = '') then
    begin
      edGamelist.Text := edRomPath.Text + '/gamelist.xml';
      acSaveEmuInfo.Execute;

      EmuConfig.Gamelist := Lin2Win(edBasePath.Text, edGamelist.Text);
    end;

    WriteXMLFile(Xml, EmuConfig.Gamelist);
    WriteLog(EmuConfig.Gamelist + ' - ' + I18N_CREATED);
  finally
    if Xml <> nil then
      Xml.Free;
    SQLite3Connection.Connected := False;
  end;
end;

procedure TFormMain.acAboutExecute(Sender: TObject);
begin
  ShowMessage('Author: ryusatgat (https://www.ryugod.com)');
end;

procedure TFormMain.acAddRomExecute(Sender: TObject);
var
  Ext: String;
  Filenames: array of String;
  i: Integer;
begin
  if cboEmulator.Items.Count = 0 then
  begin
    ShowMessage(I18N_NOSELEMUL);
    exit;
  end;

  Filenames := [];
  Ext := '*.' + StringReplace(edExtList.Text, '|', ';*.', [rfReplaceAll]);
  with TOpenDialog.Create(Self) do
  try
    Options := Options + [ofAllowMultiSelect];
    Filter := 'Rom file|' + Ext;

    if Execute then
    begin
      SetLength(Filenames, Files.Count);
      for i:=0 to Files.Count-1 Do
        Filenames[i] := Files[i];
      FormDropFiles(Self, Filenames);
    end;
  finally
    Free;
  end;
end;

procedure TFormMain.acChangeImageExecute(Sender: TObject);
var
  Key, ImageFile, Ext: String;
begin
  if ListView.Selected = nil then
  begin
    ShowMessage(I18N_ROMNOTSELECTED);
    exit;
  end;

  with TOpenDialog.Create(Self) do
  try
    Filter := 'Image file|*.png;*.jpg;*.jpeg';
    if Execute then
    begin
      Image.Picture.LoadFromFile(FileName);
      Ext := ExtractFileExt(FileName);

      Key := ListView.Selected.SubItems[1];
      ImageFile := EmuConfig.ImgPath + DirectorySeparator + ExtractFileNameWithoutExt(ExtractFilename(FileName)) + Ext;
      SaveImage(Image, ImageFile);

      ImageFile :=  EmuConfig.EmuPath + '/' + edImagePath.Text + '/' + ExtractFileNameWithoutExt(ExtractFilename(FileName)) + Ext;
      ListView.Selected.SubItems[0] := ImageFile;
      UpdateCache(Key, 'imgpath', ImageFile);
    end;
  finally
    Free;
  end;
end;

procedure TFormMain.acDeleteExecute(Sender: TObject);
var
  i: Integer;
  Key: String;
  ImgPath, RomPath: String;
begin
  if ListView.Selected = nil then
    exit;
  if Application.MessageBox(PChar(I18N_DELETECONFIRM),
    PChar(I18N_CONFIRM), MB_ICONQUESTION + MB_YESNO) <> IDYES then
    exit;

  for i:=ListView.Items.Count-1 downto 0 do
    if ListView.Items[i].Selected then
    begin
      Key := ListView.Items[i].SubItems[1];
      ImgPath := Lin2Win(edBasePath.Text, ListView.Items[i].SubItems[0]);
      RomPath := Lin2Win(edBasePath.Text, ListView.Items[i].SubItems[2]);
      if FileExists(ImgPath) then
      begin
        SysUtils.DeleteFile(ImgPath);
        WriteLog(I18N_DELETED + ' - ' + ImgPath);
      end;
      if FileExists(RomPath) then
      begin
        SysUtils.DeleteFile(RomPath);
        WriteLog(I18N_DELETED + ' - ' + RomPath);
      end;
      ListView.Items.Delete(i);
      DeleteCache(Key);
    end;
end;

procedure TFormMain.acDetectBasePathExecute(Sender: TObject);
var
  Drv: String;
  Path: String;
{$IFDEF linux}
  i: Integer;
  List: TStringList;
{$ENDIF}
begin
{$IFDEF linux}
  RunCommand('/bin/bash', ['-c', 'grep vfat /proc/mounts'], Drv);
  List := TStringList.Create;
  try
    List.Delimiter := LineEnding;
    List.DelimitedText := Drv;
    for i:=0 to List.Count-1 do
    begin
      if Copy(List.Strings[i], 1, 6) = '/media' then
      begin
        Path := List.Strings[i];
        if DirectoryExists(Path + '/Emus') then
        begin
          edBasePath.Text := Path;
          btRefresh.Click;
          break;
        end;
      end;
    end;
  finally
    List.Free;
  end;
{$ELSE}
  for Drv in 'DEFGHIJK' do
  begin
    Path := Drv + ':\';

    if DirectoryExists(Path + '\Emus') then
    begin
      edBasePath.Text := Path;
      btRefresh.Click;
      break;
    end;
  end;
{$ENDIF}
end;

procedure TFormMain.acExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.acGenerateCacheExecute(Sender: TObject);
begin
  if Application.MessageBox(PChar(I18N_RECACHECONFIRM),
    PChar(I18N_CONFIRM), MB_ICONQUESTION + MB_YESNO) <> IDYES then
    exit;

  BuildCache;
  cboEmulatorChange(cboEmulator);
end;

procedure TFormMain.acOpenBasePathExecute(Sender: TObject);
begin
  with TSelectDirectoryDialog.Create(nil) do
  try
    if Execute then
    begin
      edBasePath.Text := FileName;
      btRefresh.Click;
    end;
  finally
    Free;
  end;
end;

procedure TFormMain.acOpenImagePosExecute(Sender: TObject);
var
   OStr: String;
begin
{$IFDEF Linux}
  if Image.Hint <> '' then
    RunCommand('open', [Image.Hint], OStr);
{$ELSE}
    RunCommand('explorer.exe', ['/select,"' + Image.Hint + '"'], OStr);
{$ENDIF}
end;

procedure TFormMain.acRefreshExecute(Sender: TObject);
begin
  LoadEmus(edBasePath.Text);
  cboEmulatorChange(cboEmulator);
end;

procedure TFormMain.cboEmulatorChange(Sender: TObject);
begin
  if cboEmulator.Items.Count = 0 then
    exit;

  LoadEmuConfig(cboEmulator.Text);
  LoadEmuInfo(cboEmulator.Text);

  if not FileExists(EmuConfig.CachePath) then
    BuildCache;
  GetEmuList;
end;

procedure TFormMain.edSearchKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    btScrape.Click;
end;

procedure TFormMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  WriteSettings;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  InitCriticalSection(CriticalSection);
  IPCServer := TSimpleIPCServer.Create(nil);
{$ifdef linux}
  Application.OnIdle := @AppIdle;
{$endif}
  IPCServer.ServerID := 'WriteLog';
  IPCServer.OnMessageQueued := @IPCServerMessage;
  IPCServer.Global := True;
  IPCServer.StartServer;

  SystemMap := TStringList.Create;

  SystemMap.Add('DC=Sega Dreamcast');
  SystemMap.Add('FC=nes');
  SystemMap.Add('FDS=Famicom Disk System');
  SystemMap.Add('FBNEO=arcade');
  SystemMap.Add('CPS1=arcade');
  SystemMap.Add('CPS2=arcade');
  SystemMap.Add('CPS3=arcade');
  SystemMap.Add('GB=gb');
  SystemMap.Add('GBA=gba');
  SystemMap.Add('GBC=gbc');
  SystemMap.Add('GG=Sega Game Gear');
  SystemMap.Add('GW=Nintendo Game & Watch');
  SystemMap.Add('LYNX=Atari Lynx');
  SystemMap.Add('MAME=arcade');
  SystemMap.Add('MAME2003PLUS=arcade');
  SystemMap.Add('MAME2010=arcade');
  SystemMap.Add('MD=megadrive');
  SystemMap.Add('MS=mastersystem');
  SystemMap.Add('N64=Nintendo 64');
  SystemMap.Add('NAOMI=Sega NAOMI');
  SystemMap.Add('NGP=ngp');
  SystemMap.Add('NEOGEO=arcade');
  SystemMap.Add('OPERA=3DO');
  SystemMap.Add('PCE=pcengine');
  SystemMap.Add('PCECD=pcengine');
  SystemMap.Add('PGM=PolyGame Master');
  SystemMap.Add('PS=Sony Playstation');
  SystemMap.Add('PSP=Sony PSP');
  SystemMap.Add('PSPMINIS=Sony PSP Minis');
  SystemMap.Add('SATURN=Sega Saturn');
  SystemMap.Add('SCD=Sega CD');
  SystemMap.Add('SEGA32X=sega32x');
  SystemMap.Add('SFC=snes');
  SystemMap.Add('SFX=SuperGrafx');
  SystemMap.Add('SG1000=Sega SG-1000');
  SystemMap.Add('SGB=Super Game Boy');
  SystemMap.Add('VB=Nintendo Virtual Boy');
  SystemMap.Add('DOS=DOSBOX');
  SystemMap.Add('WS=wonderswan');
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  SQLName.Close;
  SQLite3Name.Connected := False;

  IPCServer.StopServer;
  IPCServer.Free;
  QueueThread.Terminate;
  QueueThread.WaitFor;
  QueueThread.Free;
  SystemMap.Free;

  DoneCriticalSection(CriticalSection);
end;

procedure TFormMain.FormDropFiles(Sender: TObject;
  const FileNames: array of string);
var
  Key, ImageFile, Ext, Filename, Fullname: String;
  Path: String;
  i: Integer;
begin
  if cboEmulator.Items.Count = 0 then
    exit;

  for i:=0 to Length(FileNames)-1 do
  begin
    Ext := ExtractFileExt(FileNames[i]);
    if Pos(Copy(Ext, 2), EmuConfig.ExtList) > 0 then
    begin
      Filename := ExtractFileNameWithoutExt(ExtractFileName(Filenames[i]));
      Fullname := InsertCache(ExtractFileName(Filenames[i]));
      if Fullname = '' then
        exit;
      Path := EmuConfig.RomPath + '\' + Filename + Ext;
      Path := StringReplace(Path, '..\..', edBasePath.Text, [rfReplaceAll]);
      CopyFile(Filenames[i], Path);
      WriteLog(Filenames[i] + ' --> ' + Path);
      GetEmuList;
    end else
    begin
      if ListView.Selected = nil then
      begin
        ShowMessage(I18N_ROMNOTSELECTED);
        exit;
      end;

      case FileNames[0] of
      '.jpg','.jpeg','.png':
      else
        exit;
      end;
      Ext := ExtractFileExt(FileNames[0]);
      Image.Picture.LoadFromFile(FileNames[0]);
      Key := ListView.Selected.SubItems[1];
      Filename := ExtractFileName(Lin2Win(edBasePath.Text, ListView.Selected.SubItems[2]));
      ImageFile := EmuConfig.ImgPath + DirectorySeparator + ExtractFileNameWithoutExt(Filename) + Ext;
      SaveImage(Image, ImageFile);

      ImageFile :=  EmuConfig.EmuPath + edImagePath.Text + '/' + ExtractFileNameWithoutExt(FileName) + Ext;
      ListView.Selected.SubItems[0] := ImageFile;
      UpdateCache(Key, 'imgpath', ImageFile);
    end;
  end;
end;

procedure TFormMain.FormShow(Sender: TObject);
var
  DbPath: String;
begin
  ReadSettings;
  QueueThread := TQueueThread.Create(False);

  WriteLog(I18N_ROMFROM);

  DbPath := ExtractFileDir(Application.ExeName) + DirectorySeparator + 'romnames.db';
  if not FileExists(DbPath) then
    WriteLog('romnames.db - ' + I18N_FILENOTFOUND)
  else
    SQLite3Name.DatabaseName := DbPath;

  btAutoDetect.Click;
end;

procedure TFormMain.ListViewCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if not FileExists(Lin2Win(edBasePath.Text, Item.SubItems[2])) then
    TListView(Sender).Canvas.Brush.Color := $00FF80FF
  else if not FileExists(Lin2Win(edBasePath.Text, Item.SubItems[0])) then
    TListView(Sender).Canvas.Brush.Color := $0080FFFF;
end;

procedure TFormMain.ListViewEdited(Sender: TObject; Item: TListItem;
  var AValue: string);
begin
  if not RenameTitle(Item.SubItems[1], AValue) then
  begin
    AValue := Item.Caption;
    exit;
  end;
end;

procedure TFormMain.ListViewSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  ImagePath: String;
begin
  if not Selected then
  begin
    acScrape.Enabled := False;
    exit;
  end;
  ImagePath := Lin2Win(edBasePath.Text, Item.SubItems[0]);
  acScrape.Enabled := True;
  Image.Hint := ImagePath;

  if FileExists(ImagePath) then
    Image.Picture.LoadFromFile(ImagePath)
  else
    Image.Picture.Assign(NoImage.Picture);
end;

procedure TFormMain.MenuItem15Click(Sender: TObject);
begin

end;

procedure TFormMain.mnLangKorClick(Sender: TObject);
begin
  mnLangKor.Checked := False;
  mnLangEng.Checked := False;
  TMenuItem(Sender).Checked := True;
  Translate(TMenuItem(Sender).Hint);
end;


procedure TFormMain.AppIdle(Sender: TObject; var Done: Boolean);
begin
  IPCServer.PeekMessage(1, True);
end;

procedure TFormMain.IPCServerMessage(Sender: TObject);
var
  ImageFile, Key, System: String;
  StrArr: TStringArray;
  i: Integer;
begin
  IPCServer.ReadMessage;
  if (Copy(IPCServer.StringMessage, 1, 1) = '@') then
  begin
    StrArr := Copy(IPCServer.StringMessage, 2).Split('|');
    ImageFile := StrArr[0];
    System := Strarr[1];
    Key := StrArr[2];

    if FileExists(ImageFile) then
    begin
      Image.Picture.LoadFromFile(ImageFile);
      Image.Hint := ImageFile;

      if System = cboEmulator.Text then
        for i:=0 to ListView.Items.Count-1 do
          if ListView.Items[i].SubItems[1] = Key then
          begin
            ImageFile :=  EmuConfig.EmuPath + '/' + edImagePath.Text + '/' + ExtractFileName(ImageFile);
            ListView.Items[i].SubItems[0] := ImageFile;
            UpdateCache(Key, 'imgpath', ImageFile);
            break;
          end;
    end;
  end else
    WriteLog(IPCServer.StringMessage);
end;

procedure TFormMain.LoadEmus(BasePath: String);
var
  SearchRec: TSearchRec;
  EmuPath: String;
begin
  EmuPath := BasePath + DirectorySeparator + 'Emus';

  if not DirectoryExists(EmuPath) then
  begin
    WriteLog(EmuPath + ' - ' + I18N_DIRNOTFOUND);
    exit;
  end;

  cboEmulator.Clear;

	if FindFirst(EmuPath + DirectorySeparator + '*', faDirectory, SearchRec) = 0 then
  begin
		repeat
			if Copy(SearchRec.Name, 1, 1) <> '.' then
      begin
        if not FileExists(EmuPath + DirectorySeparator + SearchRec.Name + DirectorySeparator + 'config.json') then
          WriteLog(EmuPath + DirectorySeparator + SearchRec.Name + DirectorySeparator + 'config.json - ' + I18N_FILENOTFOUND)
        else begin
          if LoadEmuConfig(SearchRec.Name) then
          begin
            if not DirectoryExists(EmuConfig.RomPath) then
              WriteLog(EmuConfig.RomPath + ' - ' + I18N_FILENOTFOUND)
            else
              cboEmulator.Items.AddStrings(SearchRec.Name);
          end;
        end;
      end;
      Application.ProcessMessages;
    until FindNext(SearchRec) <> 0;

    SysUtils.FindClose(SearchRec);
  end;

  if cboEmulator.Items.Count > 0 then
  begin
    btGenerateCache.Enabled := True;
    cboEmulator.ItemIndex := 0;
//    LoadEmuConfig(cboEmulator.Text);
  end else
    btGenerateCache.Enabled := False;
end;

procedure TFormMain.WriteLog(Log: String);
begin
  mmLog.Lines.Add(Format('[%s] %s', [TimeToStr(Now), Log]));
//  mmLog.SelStart := MaxInt;
end;

function TFormMain.LoadEmuConfig(System: String): Boolean;
var
  EmuPath: String;
  JConfig: TJSONConfig;
begin
  EmuPath := edBasePath.Text + DirectorySeparator + 'Emus' + DirectorySeparator + System;
  SetCurrentDir(EmuPath);
  EmuPath := EmuPath + DirectorySeparator + 'config.json';

  if not FileExists(EmuPath) then
  begin
    WriteLog(EmuPath + ' - ' + I18N_FILENOTFOUND);
    Result := False;
    exit;
  end;
  JConfig := TJSONConfig.Create(nil);
  try
    try
      JConfig.Filename := EmuPath;

      EmuConfig.System := System;
      EmuConfig.EmuPath := BASE_PATH + '/Emus/' + EmuConfig.System;
      EmuConfig.Caption:= String(JConfig.GetValue('/label', ''));
      EmuConfig.Icon   := String(JConfig.GetValue('/icon', ''));
      EmuConfig.RomPath := Lin2Win(edBasePath.Text, String(JConfig.GetValue('/rompath' , '../../Roms/' + System)));
      EmuConfig.CachePath := EmuConfig.RomPath + DirectorySeparator + System + '_cache7.db';
      EmuConfig.Gamelist := Lin2Win(edBasePath.Text, String(JConfig.GetValue('/gamelist', '')));
      EmuConfig.ImgPath := Lin2Win(edBasePath.Text, String(JConfig.GetValue('/imgpath' , '../Imgs/' + System)));
      if Copy(EmuConfig.ImgPath, 1, 5) = '..' + DirectorySeparator + '..' then
        EmuConfig.ImgPath := StringReplace(EmuConfig.ImgPath, '..' + DirectorySeparator + '..', edBasePath.Text, [rfReplaceAll]);
      EmuConfig.Shortname := JConfig.GetValue('/shortname', 0) = 1;
      EmuConfig.HideBios := JConfig.GetValue('/hidebios', 0) = 1;
      EmuConfig.UseSwap := JConfig.GetValue('/useswap', 0) = 1;
      EmuConfig.ExtList:= String(JConfig.GetValue('/extlist', 'zip'));
    except
      on E: Exception do
      begin
        WriteLog(EmuConfig.System + ' - config.json : ' + E.Message);
        Result := False;
        exit;
      end;
    end;

  finally
    JConfig.Free;
  end;
  Result := True;
end;

function TFormMain.LoadEmuInfo(System: String): Boolean;
var
  EmuPath: String;
  JConfig: TJSONConfig;
begin
  EmuPath := edBasePath.Text + DirectorySeparator + 'Emus' + DirectorySeparator + System + DirectorySeparator + 'config.json';

  if not FileExists(EmuPath) then
  begin
    WriteLog(EmuPath + ' - ' + I18N_FILENOTFOUND);
    Result := False;
    exit;
  end;
  JConfig := TJSONConfig.Create(nil);
  try
    JConfig.Filename := EmuPath;

    edLabel.Text := String(JConfig.GetValue('/label', ''));
    edIcon.Text := String(JConfig.GetValue('/icon', ''));
    edRomPath.Text := String(JConfig.GetValue('/rompath' , '../../Roms/' + System));
    edGamelist.Text := String(JConfig.GetValue('/gamelist', ''));
    edImagePath.Text := String(JConfig.GetValue('/imgpath' , '../Imgs/' + System));
    ckShortname.Checked := JConfig.GetValue('/shortname', 0) = 1;
    ckHideBios.Checked := JConfig.GetValue('/hidebios', 0) = 1;
    ckUseSwap.Checked := JConfig.GetValue('/useswap', 0) = 1;
    edExtList.Text := String(JConfig.GetValue('/extlist', 'zip'));
  finally
    JConfig.Free;
  end;
  Result := True;
end;

function TFormMain.SaveEmuConfig(System: String): Boolean;
var
  EmuPath: String;
begin
  EmuPath := edBasePath.Text + DirectorySeparator + 'Emus' + DirectorySeparator + System + DirectorySeparator + 'config.json';

  if not FileExists(EmuPath) then
  begin
    WriteLog(EmuPath + ' - ' + I18N_FILENOTFOUND);
    Result := False;
    exit;
  end;

  Result := True;
end;

procedure TFormMain.BuildCache;
var
  Count, AddedCount: Integer;
  Info: TSearchRec;
  Path, ImgPath, Shortname, Fullname: String;
begin
  SQLite3Connection.DatabaseName := EmuConfig.CachePath;
  if not SQLite3Connection.Connected then
    SQLite3Connection.Connected := True;

  WriteLog(EmuConfig.System + ' - ' + I18N_GENCACHE);
  Count := 0;
  AddedCount := 0;
  try
    SQLQuery.SQL.Text :=
      Format('CREATE TABLE IF NOT EXISTS %s_roms (id INTEGER NOT NULL, disp TEXT NOT NULL,	path TEXT NOT NULL,	imgpath TEXT NOT NULL, type INTEGER NULL, ppath TEXT NOT NULL, pinyin TEXT NOT NULL, cpinyin TEXT NOT NULL, opinyin TEXT NOT NULL,	PRIMARY KEY (id))',
      [EmuConfig.System]);
    SQLQuery.ExecSQL;
    if FindFirst(EmuConfig.RomPath + DirectorySeparator + '*' , faAnyFile, Info) = 0 then
    begin
      repeat
        if (Copy(Info.Name, 1, 1) <> '.') and (Pos(Copy(ExtractFileExt(Info.Name), 2), EmuConfig.ExtList) > 0) then
        begin
          Shortname := ExtractFileNameWithoutExt(ExtractFileName(Info.Name));
          FullName := GetFullTitle(Shortname, Shortname);
          SQLQuery.SQL.Text := Format('UPDATE %s_roms SET disp = %s WHERE opinyin = %s', [EmuConfig.System, QuotedStr(FullName), QuotedStr(Shortname)]);
          SQLQuery.ExecSQL;
          if SQLQuery.RowsAffected = 0 then
          begin
            Inc(AddedCount);
            Path := EmuConfig.EmuPath + '/' + edRomPath.Text + '/' + Shortname + ExtractFileExt(Info.Name);
            ImgPath := EmuConfig.EmuPath + '/' + edImagePath.Text + '/' + Shortname;
            if FileExists(Lin2Win(edBasePath.Text, ImgPath + '.jpg')) then
              ImgPath := ImgPath + '.jpg'
            else
              ImgPath := ImgPath + '.png';
            SQLQuery.SQL.Text := Format('INSERT INTO %s_roms (disp, path, imgpath, type, ppath, pinyin, cpinyin, opinyin) VALUES (%s, %s, %s, 0, ''.'', %s, %s, %s)',
              [EmuConfig.System, QuotedStr(Fullname), QuotedStr(Path), QuotedStr(ImgPath), QuotedStr(Fullname), QuotedStr(Fullname), QuotedStr(Shortname)]);
            SQLQuery.ExecSQL;
          end;
        end;

        Inc(Count);

        if Count mod 100 = 0 then
        begin
          WriteLog(I18N_PROCESSING + '... ' + IntToStr(Count));
          Application.ProcessMessages;
        end;
      until FindNext(Info) <> 0;
    end;
  finally
    SQLite3Connection.Connected := False;
    WriteLog(IntToStr(AddedCount) + ' - ' + I18N_ADDED);
  end;
end;

procedure TFormMain.GetEmuList;
var
  Title, Shortname: String;
begin
  ListView.Items.Clear;
  SQLite3Connection.DatabaseName := EmuConfig.CachePath;
  if not SQLite3Connection.Connected then
    SQLite3Connection.Connected := True;

  ListView.BeginUpdate;
  try
    SQLQuery.SQL.Text := Format('SELECT id, disp, path, imgpath, pinyin, opinyin FROM %s_roms', [EmuConfig.System]);
    try
      SQLQuery.Active := True;
    except
      on E :Exception do
      begin
        WriteLog(I18N_ERROROCCURED + ' - ' + EmuConfig.System + '_roms - ' + E.Message);
        exit;
      end;
    end;
    SQLQuery.First;

    while not SQLQuery.EOF do
    begin
      with ListView.Items.Add do
      begin
        Shortname := SQLQuery.FieldByName('opinyin').AsString;
        Title := SQLQuery.FieldByName('disp').AsString;
        Caption := Title;
        SubItems.Add(SQLQuery.FieldByName('imgpath').AsString);
        SubItems.Add(Shortname);
        SubItems.Add(SQLQuery.FieldByName('path').AsString);
      end;

      SQLQuery.Next;
    end;
  finally
    ListView.EndUpdate;
    SQLite3Connection.Connected := False;
  end;
end;

function TFormMain.RenameTitle(Key, Tobe: String): Boolean;
begin
  Result := False;
  if Tobe = '' then
    exit;

  Result := UpdateCache(Key, 'disp', Tobe);
  if Result then
    Result := UpdateRomName(Key, Tobe);
end;

function TFormMain.InsertCache(Filename: String): String;
var
  Path, ImgPath, Shortname, Fullname: String;
begin
  SQLite3Connection.DatabaseName := EmuConfig.CachePath;
  if not SQLite3Connection.Connected then
    SQLite3Connection.Connected := True;

  WriteLog(EmuConfig.System + ' - ' + I18N_GENCACHE);

  try
    SQLQuery.SQL.Text :=
      Format('CREATE TABLE IF NOT EXISTS %s_roms (id INTEGER NOT NULL, disp TEXT NOT NULL,	path TEXT NOT NULL,	imgpath TEXT NOT NULL, type INTEGER NULL, ppath TEXT NOT NULL, pinyin TEXT NOT NULL, cpinyin TEXT NOT NULL, opinyin TEXT NOT NULL,	PRIMARY KEY (id))',
      [EmuConfig.System]);
    SQLQuery.ExecSQL;

    Shortname := ExtractFileNameWithoutExt(ExtractFilename(Filename));
    Fullname := GetFullTitle(Shortname, Shortname);
    Result := Fullname;
    Path := EmuConfig.EmuPath + '/' + edRomPath.Text + '/' + Filename;
    SQLQuery.SQL.Text := Format('UPDATE %s_roms SET disp = %s, path = %s WHERE opinyin = %s', [EmuConfig.System, QuotedStr(FullName), QuotedStr(Path), QuotedStr(Shortname)]);
    SQLQuery.ExecSQL;
    if SQLQuery.RowsAffected = 0 then
    begin
      ImgPath := EmuConfig.EmuPath + '/' + edImagePath.Text + '/' + Shortname + '.png';
      SQLQuery.SQL.Text := Format('INSERT INTO %s_roms (disp, path, imgpath, type, ppath, pinyin, cpinyin, opinyin) VALUES (%s, %s, %s, 0, ''.'', %s, %s, %s)',
        [EmuConfig.System, QuotedStr(Fullname), QuotedStr(Path), QuotedStr(ImgPath), QuotedStr(Fullname), QuotedStr(Fullname), QuotedStr(Shortname)]);
      SQLQuery.ExecSQL;
    end;
  finally
    SQLite3Connection.Connected := False;
    WriteLog(Filename + ' - ' + I18N_ADDED);
  end;
end;

function TFormMain.UpdateCache(Key, Column, Value: String): Boolean;
begin
  SQLite3Connection.DatabaseName := EmuConfig.CachePath;
  if not SQLite3Connection.Connected then
    SQLite3Connection.Connected := True;

  Result := False;

  EnterCriticalSection(CriticalSection);

  try
    SQLQuery.SQL.Text := Format('UPDATE %s_roms SET %s = %s WHERE opinyin = %s', [EmuConfig.System, Column, QuotedStr(Value), QuotedStr(Key)]);
    try
      SQLQuery.ExecSQL;
    except
      on E :Exception do
      begin
        WriteLog(I18N_ERROROCCURED + ' - ' + Value + ' - ' + E.Message);
        exit;
      end;
    end;
    Result := True;
    WriteLog(I18N_SAVED + ' - ' + Value);
  finally
    SQLite3Connection.Connected := False;
    LeaveCriticalSection(CriticalSection);
  end;
end;

function TFormMain.DeleteCache(Key: String): Boolean;
begin
  SQLite3Connection.DatabaseName := EmuConfig.CachePath;
  if not SQLite3Connection.Connected then
    SQLite3Connection.Connected := True;

  Result := False;

  EnterCriticalSection(CriticalSection);

  try
    SQLQuery.SQL.Text := Format('DELETE FROM %s_roms WHERE opinyin = %s', [EmuConfig.System, QuotedStr(Key)]);
    try
      SQLQuery.ExecSQL;
    except
      on E :Exception do
      begin
        WriteLog(I18N_ERROROCCURED + ' - ' + E.Message);
        exit;
      end;
    end;
    Result := True;
    WriteLog(I18N_DELETED + ' - ' + Key);
  finally
    SQLite3Connection.Connected := False;
    LeaveCriticalSection(CriticalSection);
  end;
end;

function TFormMain.GetFullTitle(Title, DefaultTitle: String): String;
var
  ColName: String;
begin
  if mnLangKor.Checked then
    ColName := 'name'
  else
    ColName := 'ename';
  if not SQLite3Name.Connected then
  begin
    SQLite3Name.Connected := True;
  end;
  SQLName.SQL.Text := Format('SELECT name, ename FROM romnames WHERE system = %s AND shortname = %s',
    [QuotedStr(SystemMap.Values[EmuConfig.System]), QuotedStr(Title)]);
  SQLName.Open;

  try
    SQLName.First;
    if SQLName.Eof then
      Result := DefaultTitle
    else
      Result := SQLName.FieldByName(ColName).AsString;
  finally
    SQLName.Close;
  end;
end;

function TFormMain.UpdateRomName(Key, Value: String): Boolean;
begin
  SQLName.SQL.Text := Format('UPDATE romnames SET name = %s WHERE system = %s AND shortname = %s', [QuotedStr(Value), QuotedStr(SystemMap.Values[EmuConfig.System]), QuotedStr(Key)]);
  try
    SQLName.ExecSQL;
  except
    on E :Exception do
    begin
      WriteLog(I18N_ERROROCCURED + ' - ' + Value + ' - ' + E.Message);
      Result := False;
      exit;
    end;
  end;
  Result := True;
end;

procedure TFormMain.ReadSettings;
var
  IniFile, Lang: String;
begin
  IniFile := ExtractFilePath(Application.ExeName) +
          ExtractFileNameOnly(Application.ExeName) + '.ini';
  with TIniFile.Create(IniFile) do
  try
    Lang := ReadString('Main', 'Lang', 'KO');
    if Lang = 'EN' then
      mnLangEng.Click;
  finally
    Free;
  end;
end;

procedure TFormMain.WriteSettings;
var
  IniFile, Lang: String;
begin
  IniFile := ExtractFilePath(Application.ExeName) +
          ExtractFileNameOnly(Application.ExeName) + '.ini';

  if mnLangKor.Checked then
    Lang := 'KO'
  else
    Lang := 'EN';
  with TIniFile.Create(IniFile) do
  try
    WriteString('Main', 'Lang', Lang);
  finally
    Free;
  end;
end;


end.
