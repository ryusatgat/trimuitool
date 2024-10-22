unit MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, dbf, SQLite3Conn, SQLDB, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, ActnList, Menus, DBGrids, Buttons,
  fpjson, jsonparser, jsonConf, openssl, opensslsockets, fphttpclient, DOM,
  XMLRead, XMLWrite, xmltextreader, simpleipc, LazFileUtils, LCLTranslator,
  RegExpr, httpprotocol, LCLType, process, dynlibs, fileutil, Translations,
  LResources, ShellCtrls, StrUtils, lclintf;

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
    System, Key, ImagePath, SearchStr, Gamelist, ImageBase, EmuPath: String;
    IsShortname, IsForce, ForcePng: Boolean;
  end;

  { TQueueThread }

  TQueueThread = class(TThread)
  private
    HttpClient: TFPHttpClient;
    Image: TImage;
    class var BasePath: String;
    class var IPCClient: TSimpleIPCClient;
    class var ScrapeList: TList;
    class var Count, TotalCount: Integer;
  public
    constructor Create(CreateSuspended: boolean);
    destructor Destroy; override;
    procedure Execute; override;
    class procedure SetBasePath(Path: String); static;
    class procedure CancelScrape; static;
    class procedure Put(ScrapeInfo: TScrapeInfo); static;
    function Get(var ScrapeInfo: TScrapeInfo): Boolean;
    procedure Scrape(ScrapeInfo: TScrapeInfo; IsArcade: Boolean);
    class procedure WriteLog(Log: String); static;
  end;

  { TFormMain }

  TFormMain = class(TForm)
    acCacheFromXml: TAction;
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
    acMkDir: TAction;
    acGithub: TAction;
    acRmDir: TAction;
    acScanExt: TAction;
    acScrapeTotal: TAction;
    ActionList: TActionList;
    btGenerateCache: TButton;
    btOpen: TButton;
    btAutoDetect: TButton;
    btRefresh: TButton;
    btScanExt: TButton;
    btScrape: TButton;
    btSaveEmuInfo: TButton;
    C1: TMenuItem;
    cboEmulator: TComboBox;
    ckForcePng: TCheckBox;
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
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    ImageList: TImageList;
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
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    mnLanguage: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem27: TMenuItem;
    MenuItem28: TMenuItem;
    MenuItem29: TMenuItem;
    MenuItem30: TMenuItem;
    MenuItem31: TMenuItem;
    MenuItem32: TMenuItem;
    mnXML: TMenuItem;
    mnLangKor: TMenuItem;
    mnLangEng: TMenuItem;
    Panel1: TPanel;
    pmDir: TPopupMenu;
    pbInfo: TProgressBar;
    Separator4: TMenuItem;
    Separator3: TMenuItem;
    Separator2: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    mnFile: TMenuItem;
    mnHelp: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    mnScrape: TMenuItem;
    Separator1: TMenuItem;
    mmLog: TMemo;
    N1: TMenuItem;
    NoImage: TImage;
    pnImage: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    pmScrape: TMenuItem;
    pmPopup: TPopupMenu;
    pmImage: TPopupMenu;
    Rename1: TMenuItem;
    RescrapeAll1: TMenuItem;
    Scrapemissing1: TMenuItem;
    Splitter1: TSplitter;
    SQLite3Connection: TSQLite3Connection;
    SQLite3Name: TSQLite3Connection;
    SQLQuery: TSQLQuery;
    SQLName: TSQLQuery;
    SQLTransaction: TSQLTransaction;
    SQLTransactionName: TSQLTransaction;
    TreeView: TTreeView;
    procedure acAboutExecute(Sender: TObject);
    procedure acAddRomExecute(Sender: TObject);
    procedure acBuildGamelistExecute(Sender: TObject);
    procedure acCacheFromXmlExecute(Sender: TObject);
    procedure acCancelScrapeExecute(Sender: TObject);
    procedure acChangeImageExecute(Sender: TObject);
    procedure acDeleteExecute(Sender: TObject);
    procedure acDetectBasePathExecute(Sender: TObject);
    procedure acExitExecute(Sender: TObject);
    procedure acGenerateCacheExecute(Sender: TObject);
    procedure acGithubExecute(Sender: TObject);
    procedure acMkDirExecute(Sender: TObject);
    procedure acOpenBasePathExecute(Sender: TObject);
    procedure acOpenImagePosExecute(Sender: TObject);
    procedure acRefreshExecute(Sender: TObject);
    procedure acRenameExecute(Sender: TObject);
    procedure acRmDirExecute(Sender: TObject);
    procedure acSaveEmuInfoExecute(Sender: TObject);
    procedure acScanExtExecute(Sender: TObject);
    procedure acScrapeExecute(Sender: TObject);
    procedure acScrapeMissingExecute(Sender: TObject);
    procedure acScrapeTotalExecute(Sender: TObject);
    procedure btOpenClick(Sender: TObject);
    procedure cboEmulatorChange(Sender: TObject);
    procedure edSearchKeyPress(Sender: TObject; var Key: char);
    procedure FormClose(Sender: TObject; var {%H-}CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure ListViewCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      {%H-}State: TCustomDrawState; var {%H-}DefaultDraw: Boolean);
    procedure ListViewEdited(Sender: TObject; Item: TListItem;
      var AValue: string);
    procedure ListViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure mnLangKorClick(Sender: TObject);
    procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure TreeViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreeViewDragOver(Sender, Source: TObject; {%H-}X, {%H-}Y: Integer;
      {%H-}State: TDragState; var Accept: Boolean);
    procedure TreeViewEdited(Sender: TObject; Node: TTreeNode; var S: string);
  private
    procedure AppIdle(Sender: TObject; var {%H-}Done: Boolean);
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
    procedure BuildCache(IsDelete: Boolean=False);
    procedure GetSubDir;
    procedure GetEmuList(SubDir: String='.');
    function RenameTitle(Key, Tobe: String): Boolean;
    function RenameSubDir(Asis, Tobe: String): Boolean;
    function DeleteSubDir: Boolean;
    function InsertCache(Filename: String; SubDir: String=''): String;
    function UpdateCache(Key, Column, Value: String): Boolean;
    function DeleteCache(Key: String): Boolean;
    function ExecCacheSQL(Query: String; Args: Array of const): Boolean;
    function GetFullTitle(Title, DefaultTitle: String): String;
    function UpdateRomName(Key, Value: String): Boolean;
    procedure GenCacheFromXml(Gamelist: String);
    procedure ReadSettings;
    procedure WriteSettings;
  end;

var
  FormMain: TFormMain;
  SystemMap: TStringList;

resourcestring
  I18N_SCRAPESTARTED = ' 스크래핑이 시작되었습니다';
  I18N_ROMFROM = '롬 한글정보 출처: 텐타클팀(http://cafe.naver.com/raspigamer)';
  I18N_FILENOTFOUND = '파일을 찾을 수 없습니다';
  I18N_DIRNOTFOUND = '폴더를 찾을 수 없습니다';
  I18N_CANCELEDSCRAPE = '스크래핑이 취소되었습니다';
  I18N_CACHEFROMXML = 'gamelist.xml 파일정보로부터 캐시파일을 새로 생성합니다. 계속 하시겠습니까?';
  I18N_GENCACHE = '캐시를 생성하고 있습니다...';
  I18N_ERROROCCURED = '오류가 발생하였습니다';
  I18N_FILEEXISTS = '파일이 존재합니다';
  I18N_DIREXISTS = '폴더가 존재합니다';
  I18N_NOSELEMUL = '선택된 에뮬레이터가 없습니다';
  I18N_DONESCRAPE = '스크래핑이 완료되었습니다';
  I18N_ROMNOTSELECTED = '롬을 먼저 선택해주세요';
  I18N_SAVED = '저장되었습니다';
  I18N_CREATED = '생성되었습니다';
  I18N_PROCESSING = '처리중입니다';
  I18N_DELETED = '삭제되었습니다';
  I18N_CONFIRM = '확인';
  I18N_ADDED = '추가되었습니다';
  I18N_RECACHECONFIRM = '캐시 파일을 재생성합니다. 계속 하시겠습니까?';
  I18N_DELETECONFIRM = '롬 파일을 삭제합니다. 계속 하시겠습니까?';
  I18N_DELETEDIRCONFIRM = '폴더를 삭제합니다. 계속 하시겠습니까?';
  I18N_GAMELISTCONFIRM = '캐시로부터 gamelist.xml 파일을 새로 생성합니다. 계속 하시겠습니까?';
  I18N_MAKEDIR = '폴더생성';
  I18N_INPUTDIRNAME = '폴더명을 입력하세요';
  I18N_ADDEDEXT = '확장자가 추가되었습니다';
  I18N_SCRAPEALLCONFIRM = '에뮬레이터 전체 영역에 대해 누락 항목을 스크래핑합니다. 계속하시겠습니까?';
  I18N_DONE = '완료되었습니다';

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

function SaveImage(Image: TImage; var ImagePath: String; ForcePng: Boolean): Boolean;
var
  PngImage: TPortableNetworkGraphic;
begin
  if Image.Picture.Graphic.Classname = 'TPortableNetworkGraphic' then
  begin
    if ExtractFileExt(ImagePath) <> '.png' then
      ImagePath := ExtractFileNameWithoutExt(ImagePath) + '.png'
  end else if Image.Picture.Graphic.Classname = 'TJpegImage' then
  begin
    if ForcePng then
    begin
      PngImage := TPortableNetworkGraphic.Create;
      try
        PngImage.Assign(Image.Picture.Bitmap);
        ImagePath := ExtractFileNameWithoutExt(ImagePath) + '.png';
        Image.Picture.Bitmap.LoadFromRawImage(PngImage.RawImage, False);
      finally
        if Assigned(PngImage) then
          PngImage.Free;
      end;
    end else if ExtractFileExt(ImagePath) <> '.jpg' then
      ImagePath := ExtractFileNameWithoutExt(ImagePath) + '.jpg'
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

{ TQueueThread }

constructor TQueueThread.Create(CreateSuspended : boolean);
begin
  inherited Create(CreateSuspended);
  Image := TImage.Create(nil);

  EnterCriticalSection(CriticalSection);
  try
    HttpClient := TFPHTTPClient.Create(nil);
    if not Assigned(ScrapeList) then
      ScrapeList := TList.Create;
    if not Assigned(IPCClient) then
    begin
      IPCClient := TSimpleIPCClient.Create(nil);
      IPCClient.ServerID := 'WriteLog';
    end;

    Count := 0;
    TotalCount := 0;
  finally
    LeaveCriticalSection(CriticalSection);
  end;
end;

destructor TQueueThread.Destroy;
var
  i: Integer;
begin
  EnterCriticalSection(CriticalSection);
  try
    for i:=0 to ScrapeList.Count-1 do
      Dispose(PScrapeInfo(ScrapeList.Items[i]));

    if Assigned(ScrapeList) then
      FreeAndNil(ScrapeList);
    if Assigned(IPCClient) then
      FreeAndNil(IPCClient);
  finally
    LeaveCriticalSection(CriticalSection);
  end;

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
  ScrapeInfo.ImageBase := '';
  ScrapeInfo.EmuPath := '';
  ScrapeInfo.ForcePng := True;

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

class procedure TQueueThread.SetBasePath(Path: String); static;
begin
  BasePath := Path;
end;

class procedure TQueueThread.CancelScrape; static;
var
  i: Integer;
begin
  if ScrapeList.Count > 0 then
    WriteLog(I18N_CANCELEDSCRAPE + ' - ' + IntToStr(ScrapeList.Count));
  EnterCriticalSection(CriticalSection);

  try
    for i:=0 to ScrapeList.Count-1 do
      Dispose(PScrapeInfo(ScrapeList.Items[i]));
    ScrapeList.Clear;
  finally
    LeaveCriticalSection(CriticalSection);
  end;
end;

class procedure TQueueThread.Put(ScrapeInfo: TScrapeInfo); static;
var
  Info: PScrapeInfo;
begin
  EnterCriticalSection(CriticalSection);
  try
    Count += 1;
    TotalCount += 1;
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
      Dispose(PScrapeInfo(ScrapeList[0]));
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
  ImageCount: Integer;
  i: Integer;
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
  if Copy(ScrapeInfo.ImageBase, 1, 1) = '/' then
    ScrapeInfo.ImagePath := Lin2Win(BasePath, ScrapeInfo.ImageBase + '/' + ScrapeInfo.Key)
  else
    ScrapeInfo.ImagePath := Lin2Win(BasePath, ScrapeInfo.EmuPath + '/' + ScrapeInfo.ImageBase + '/' + ScrapeInfo.Key);

  if not DirectoryExists(ExtractFileDir(ScrapeInfo.ImagePath)) then
    MkDir(ExtractFileDir(ScrapeInfo.ImagePath));
  if FileExists(ScrapeInfo.ImagePath) and not ScrapeInfo.IsForce then
  begin
    WriteLog(ScrapeInfo.ImagePath + ' - ' + I18N_FILEEXISTS);
    exit;
  end;

  EnterCriticalSection(CriticalSection);
  try
    Count -= 1;
  finally
    LeaveCriticalSection(CriticalSection);
  end;
  ImageCount := 0;
  Stream := TMemoryStream.Create;

  try
    try
      if IsArcade then
      begin
        with HttpClient do
        begin
          JsonStr := Get('http://adb.arcadeitalia.net/service_scraper.php?ajax=query_mame&game_name=' + ScrapeInfo.SearchStr);

          JData := GetJSON(JsonStr);

          if not Assigned(JData) then
          begin
            WriteLog('No data found error - ' + ScrapeInfo.SearchStr);
            exit;
          end;

          ImageUrl := TJsonObject(JData).FindPath('result[0].url_image_ingame').AsString;
          Get(ImageUrl, Stream);
          Stream.Seek(0, soFromBeginning);
          Image.Picture.LoadFromStream(Stream);

          if not SaveImage(Image, ScrapeInfo.ImagePath, ScrapeInfo.ForcePng) then
          begin
            WriteLog('Scraping ' + ScrapeInfo.System + ' - ' + Image.Picture.Graphic.Classname + '--> File format error');
            exit;
          end;
        end;
      end else
      begin
        SysStr := ScrapeInfo.System;
        if SystemMap.Values[ScrapeInfo.System] <> '' then
          SysStr := SystemMap.Values[ScrapeInfo.System];
        try
          EnterCriticalSection(CriticalSection);
          try
            Contents := HttpClient.Get('https://images.search.yahoo.com/search/images?p=' +
              HTTPEncode(StringReplace('screenshot+gamefabrique+'+GetText(ScrapeInfo.SearchStr)+'+'+SysStr, ' ', '+', [rfReplaceAll])));
          finally
            LeaveCriticalSection(CriticalSection);
          end;
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

            Stream.Seek(0, soFromBeginning);
            Image.Picture.LoadFromStream(Stream);

            if not SaveImage(Image, ScrapeInfo.ImagePath, ScrapeInfo.ForcePng) then
            begin
              WriteLog('Scraping ' + ScrapeInfo.System + ' - ' + Image.Picture.Graphic.Classname + '--> File format error');
              exit;
            end;

            if ScrapeList.Count = 0 then
            begin
              for i:=1 to 4 do
              begin
                if RegEx.ExecNext then
                begin
                  ImageUrl := RegEx.Match[1];
                  JsonStr := ExtractFilePath(Application.ExeName) + DirectorySeparator + 'Image' + IntToStr(i) + '.jpg';
                  HttpClient.Get(ImageUrl, JsonStr);
                  Inc(ImageCount);
                end else break;
              end;
            end;
          end;
        finally
          RegEx.Free;
        end;
      end;

      WriteLog('@' + ScrapeInfo.ImagePath + '|' + ScrapeInfo.ImageBase + '|' + ScrapeInfo.Key + '|' + IntToStr(ImageCount) + '|' +
        IntToStr(Count)  + '|' + IntToStr(TotalCount));
    except
      on E :Exception do
      WriteLog(ScrapeInfo.SearchStr + I18N_ERROROCCURED + ' - ' + E.Message);
    end;
  finally
    Stream.Free;
    EnterCriticalSection(CriticalSection);
    try
      if Count = 0 then
        TotalCount := 0;
    finally
      LeaveCriticalSection(CriticalSection);
    end;
  end;
end;

class procedure TQueueThread.WriteLog(Log: String); static;
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
  ScrapeInfo.ImageBase := edImagePath.Text;
  ScrapeInfo.ForcePng := ckForcePng.Checked;
  ScrapeInfo.EmuPath := EmuConfig.EmuPath;
  TQueueThread.SetBasePath(edBasePath.Text);

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

      TQueueThread.Put(ScrapeInfo);
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
  ScrapeInfo.ImageBase := edImagePath.Text;
  ScrapeInfo.ForcePng := ckForcePng.Checked;
  ScrapeInfo.EmuPath := EmuConfig.EmuPath;
  TQueueThread.SetBasePath(edBasePath.Text);

  for i:=0 to ListView.Items.Count-1 do
  begin
    if FileExists(Lin2Win(edBasePath.Text, ListView.Items[i].SubItems[0])) then
      continue;
    ScrapeInfo.SearchStr := ListView.Items[i].SubItems[1];
    ScrapeInfo.Key := ListView.Items[i].SubItems[1];
    Filename := ExtractFilename(Lin2Win(edBasePath.Text, ListView.Items[i].SubItems[2]));
    ScrapeInfo.ImagePath := EmuConfig.ImgPath + DirectorySeparator + ExtractFileNameWithoutExt(Filename);
    TQueueThread.Put(ScrapeInfo);
  end;
end;

procedure TFormMain.acScrapeTotalExecute(Sender: TObject);
var
  ScrapeInfo: TScrapeInfo;
  Filename: String;
  EmuPath, Shortname, ImagePath, Path: String;
  SearchRec: TSearchRec;
  Count: Integer;
begin
  Count := 0;
  EmuPath := edBasePath.Text + DirectorySeparator + 'Emus';

  if not DirectoryExists(EmuPath) then
  begin
    WriteLog(EmuPath + ' - ' + I18N_DIRNOTFOUND);
    exit;
  end;

  if Application.MessageBox(PChar(I18N_SCRAPEALLCONFIRM),
    PChar(I18N_CONFIRM), MB_ICONQUESTION + MB_YESNO) <> IDYES then
    exit;

  cboEmulator.Enabled := False;
  WriteLog(I18N_SCRAPESTARTED);

  try
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
              else begin
                WriteLog(I18N_PROCESSING + ' - ' + SearchRec.Name);
                Application.ProcessMessages;
                SQLite3Connection.DatabaseName := EmuConfig.CachePath;
                if not SQLite3Connection.Connected then
                  SQLite3Connection.Connected := True;
                try
                  ScrapeInfo.Gamelist := EmuConfig.Gamelist;
                  ScrapeInfo.System := EmuConfig.System;
                  ScrapeInfo.IsShortname := EmuConfig.Shortname;
                  ScrapeInfo.IsForce := True;
                  ScrapeInfo.ImageBase := edImagePath.Text;
                  ScrapeInfo.ForcePng := ckForcePng.Checked;
                  ScrapeInfo.EmuPath := EmuConfig.EmuPath;
                  TQueueThread.SetBasePath(edBasePath.Text);

                  SQLQuery.SQL.Text := Format('SELECT id, disp, path, imgpath, pinyin, opinyin FROM %s_roms WHERE type = 0', [EmuConfig.System]);

                  try
                    SQLQuery.Active := True;
                    SQLQuery.First;

                    while not SQLQuery.EOF do
                    begin
                      Shortname := SQLQuery.FieldByName('opinyin').AsString;
                      ImagePath := SQLQuery.FieldByName('imgpath').AsString;
                      Path := SQLQuery.FieldByName('path').AsString;

                      if not FileExists(Lin2Win(edBasePath.Text, ImagePath)) then
                      begin
                        ScrapeInfo.SearchStr := Shortname;
                        ScrapeInfo.Key := Shortname;
                        Filename := ExtractFilename(Lin2Win(edBasePath.Text, Path));
                        ScrapeInfo.ImagePath := EmuConfig.ImgPath + DirectorySeparator + ExtractFileNameWithoutExt(Filename);
                        TQueueThread.Put(ScrapeInfo);
                        Inc(Count);
                      end;

                      SQLQuery.Next;
                    end;
                  except
                    on E :Exception do
                    begin
                      WriteLog(I18N_ERROROCCURED + ' - ' + EmuConfig.System + '_roms - ' + E.Message);
                    end;
                  end;
                finally
                  SQLite3Connection.Connected := False;
                end;
              end;
            end;
          end;
        end;
        Application.ProcessMessages;
      until FindNext(SearchRec) <> 0;

      SysUtils.FindClose(SearchRec);
    end;
  finally
    LoadEmuConfig(cboEmulator.Text);
    cboEmulator.Enabled := True;
  end;

  WriteLog(I18N_DONE + ' - ' + IntToStr(Count));
end;

procedure TFormMain.acRenameExecute(Sender: TObject);
begin
  if (ActiveControl is TTreeView) and Assigned(TTreeView(ActiveControl).Selected) and (TTreeView(ActiveControl).Selected.Level <> 0) then
    TTreeView(ActiveControl).Selected.EditText
  else if (ActiveControl is TListView) and Assigned(TListView(ActiveControl).Selected) then
    TListView(ActiveControl).Selected.EditCaption;
end;

procedure TFormMain.acRmDirExecute(Sender: TObject);
begin
  DeleteSubDir;
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

procedure TFormMain.acScanExtExecute(Sender: TObject);
const
  SkipExt: array  [0..10] of String =
    ('', 'bak', 'db', 'xml', 'txt', 'state', 'jpg', 'jpeg', 'png', 'gif', 'sh');
var
  ExtList: String;

  procedure ScanExt(SubDir: String; Level: Integer; var ExtList: String);
  var
    Info: TSearchRec;
    Ext: String;
    ExtArray: TStringArray;
  begin
    if FindFirst(EmuConfig.RomPath + DirectorySeparator + SubDir + DirectorySeparator + '*' , faAnyFile, Info) = 0 then
    begin
      repeat
        repeat
          if Copy(Info.Name, 1, 1) = '.' then
            break;

          if (Level = 0) and ((Info.Attr and faDirectory) = faDirectory) then
          begin
            ScanExt(Info.Name, 1, ExtList);
            break;
          end;

          ExtArray := SplitString(ExtList, '|');
          Ext := Copy(ExtractFileExt(Utf8String(Info.Name)), 2);

          if not {%H-}MatchStr(Ext, ExtArray) and not {%H-}MatchStr(LowerCase(Ext), SkipExt) then
          begin
            if ExtList = '' then
              ExtList := Ext
            else
              ExtList := ExtList + '|' + Ext;

            WriteLog(I18N_ADDEDEXT + ' - ' + Ext);
          end;
        until True;
      until FindNext(Info) <> 0;

      FindClose(Info);
    end;
  end;
begin
  ExtList := edExtList.Text;
  ScanExt('.', 0, ExtList);
  if ExtList <> edExtList.Text then
  begin
    edExtList.Text := ExtList;
    btSaveEmuInfo.Click;
  end;
end;

procedure TFormMain.acCancelScrapeExecute(Sender: TObject);
begin
  TQueueThread.CancelScrape;
  pbInfo.Visible := False;
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
    SQLQuery.SQL.Text := Format('SELECT disp, path, imgpath, type, pinyin, opinyin FROM %s_roms', [EmuConfig.System]);
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
      if SQLQuery.FieldByName('type').AsInteger = 0 then
        Node := Xml.CreateElement('game')
      else
        Node := Xml.CreateElement('folder');
      RootNode.AppendChild(Node);

      ChildNode := Xml.CreateElement('name');
      ChildNode.TextContent := SQLQuery.FieldByName('disp').AsUnicodeString;
      Node.AppendChild(ChildNode);

      ChildNode := Xml.CreateElement('image');
      ChildNode.TextContent := SQLQuery.FieldByName('imgpath').AsUnicodeString;
      Node.AppendChild(ChildNode);

      if SQLQuery.FieldByName('type').AsInteger = 0 then
      begin
        ChildNode := Xml.CreateElement('path');
//        ChildNode.TextContent := UnicodeString(StringReplace(SQLQuery.FieldByName('path').AsString, EmuConfig.EmuPath + '/', '', []));
        ChildNode.TextContent := SQLQuery.FieldByName('path').AsUnicodeString;
        Node.AppendChild(ChildNode);
      end;

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

procedure TFormMain.acCacheFromXmlExecute(Sender: TObject);
begin
  with TOpenDialog.Create(Self) do
  try
    Filter := 'gamelist file|*.xml';

    if not Execute then
      exit;

    GenCacheFromXml(FileName);
  finally
    Free;
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
  Key, ImageFile, WinFilename, Ext: String;
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
      if Copy(edImagePath.Text, 1, 1) = '/' then
        ImageFile :=  edImagePath.Text + '/' + ExtractFileNameWithoutExt(ExtractFilename(FileName)) + Ext
      else
        ImageFile :=  EmuConfig.EmuPath + '/' + edImagePath.Text + '/' + ExtractFileNameWithoutExt(ExtractFilename(FileName)) + Ext;
      WinFilename := Lin2Win(edBasePath.Text, ImageFile);
      SaveImage(Image, WinFilename, ckForcePng.Checked);

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

  BuildCache(True);
  cboEmulatorChange(cboEmulator);
end;

procedure TFormMain.acGithubExecute(Sender: TObject);
begin
  openURL('https://github.com/ryusatgat/trimuitool');
end;

procedure TFormMain.acMkDirExecute(Sender: TObject);
var
  Dir, Path: String;
begin
  if cboEmulator.Items.Count = 0 then
  begin
    ShowMessage(I18N_NOSELEMUL);
    exit;
  end;
  Dir := '';
  if not InputQuery(I18N_MAKEDIR, I18N_INPUTDIRNAME, Dir) then
    exit;
  Path := Lin2Win(edBasePath.Text, EmuConfig.EmuPath + '/' + edRomPath.Text + '/' + Dir);

  if DirectoryExists(Path) then
  begin
    ShowMessage(I18N_DIREXISTS);
    exit
  end;

  if not CreateDir(Path) then
  begin
    WriteLog(Path);
    ShowMessage(I18N_ERROROCCURED);
    exit;
  end;

  Path := EmuConfig.EmuPath + '/' + edRomPath.Text + '/' + Dir;
  ExecCacheSQL('INSERT INTO %s_roms (disp, path, imgpath, type, ppath, pinyin, cpinyin, opinyin) VALUES (%s, %s, %s, 1, ''.'', '''', '''', '''')',
              [EmuConfig.System, QuotedStr(Dir), QuotedStr(Path), QuotedStr(Path), QuotedStr(Dir)]);

  btRefresh.Click;
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
  GetSubDir;
end;

procedure TFormMain.edSearchKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    btScrape.Click;
end;

procedure TFormMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  WriteSettings;
  TQueueThread.CancelScrape;
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
  SystemMap.Add('ARCADE=arcade');
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

  QueueThread := TQueueThread.Create(False);
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  SQLName.Close;
  SQLite3Name.Connected := False;

  TQueueThread.CancelScrape;
  QueueThread.Terminate;
  QueueThread.WaitFor;
  QueueThread.Free;
  IPCServer.StopServer;
  IPCServer.Free;
  SystemMap.Free;

  DoneCriticalSection(CriticalSection);
end;

procedure TFormMain.FormDropFiles(Sender: TObject;
  const FileNames: array of string);
var
  Key, ImageFile, Ext, Filename, Fullname: String;
  Path, SubDir: String;
  i: Integer;
begin
  if cboEmulator.Items.Count = 0 then
    exit;

  for i:=0 to Length(FileNames)-1 do
  begin
    Ext := ExtractFileExt(FileNames[i]);
    if Pos(Copy(Ext, 2), EmuConfig.ExtList) > 0 then
    begin
      SubDir := TreeView.Selected.Text;
      Filename := ExtractFileNameWithoutExt(ExtractFileName(Filenames[i]));
      Fullname := InsertCache(ExtractFileName(Filenames[i]), SubDir);
      if Fullname = '' then
        exit;
      Path := EmuConfig.RomPath;
      Path := StringReplace(Path, '..' + DirectorySeparator + '..', edBasePath.Text, [rfReplaceAll]);
      if Assigned(TreeView.Selected) and (TreeView.Selected.Level > 0) then
        Path := Path + DirectorySeparator + SubDir;
      Path := Path + DirectorySeparator + Filename + Ext;
      CopyFile(Filenames[i], Path);
      WriteLog(Filenames[i] + ' --> ' + Path);
      GetEmuList(TreeView.Selected.Text);
    end else if Ext = '.xml' then
    begin
      if Application.MessageBox(PChar(I18N_CACHEFROMXML),
      PChar(I18N_CONFIRM), MB_ICONQUESTION + MB_YESNO) <> IDYES then
        exit;
      GenCacheFromXml(FileNames[0]);
      exit;
    end else begin
      if ListView.Selected = nil then
      begin
        ShowMessage(I18N_ROMNOTSELECTED);
        exit;
      end;

      case Ext of
      '.jpg','.jpeg','.png':
      else
        exit;
      end;
      Ext := ExtractFileExt(FileNames[0]);
      Image.Picture.LoadFromFile(FileNames[0]);
      Key := ListView.Selected.SubItems[1];

      Filename := ExtractFilename(FileNames[0]);
      if Copy(edImagePath.Text, 1, 1) = '/' then
        ImageFile := edImagePath.Text + '/' + ExtractFileNameWithoutExt(Filename) + Ext
      else
        ImageFile := EmuConfig.EmuPath + '/' + edImagePath.Text + '/' + ExtractFileNameWithoutExt(FileName) + Ext;

      Filename := Lin2Win(edBasePath.Text, ImageFile);
      SaveImage(Image, Filename, ckForcePng.Checked);
      ListView.Selected.SubItems[0] := ImageFile;
      UpdateCache(Key, 'imgpath', ImageFile);
      exit;
    end;
  end;
end;

procedure TFormMain.FormShow(Sender: TObject);
var
  DbPath: String;
begin
  WriteLog(I18N_ROMFROM);

  DbPath := ExtractFileDir(Application.ExeName) + DirectorySeparator + 'romnames.db';
  if not FileExists(DbPath) then
    WriteLog('romnames.db - ' + I18N_FILENOTFOUND)
  else
    SQLite3Name.DatabaseName := DbPath;

  btAutoDetect.Click;
  ReadSettings;
end;

procedure TFormMain.Image1Click(Sender: TObject);
var
  Picture: TPicture;
begin
  Picture := TPicture.Create;
  try
    if Assigned(TImage(Sender).Picture) then
    begin
      Picture.Assign(Image.Picture);
      Image.Picture.Assign(TImage(Sender).Picture);
      TImage(Sender).Picture.Assign(Picture);

      if Image.Hint <> '' then
      begin
        Image.Picture.SaveToFile(Image.Hint);
        WriteLog(I18N_SAVED + ' - ' + Image.Hint);
      end;
    end;
  finally
    if Assigned(Picture) then
      Picture.Free;
  end;
end;

procedure TFormMain.ListViewCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if not FileExists(Lin2Win(edBasePath.Text, Item.SubItems[2])) then
  begin
    TListView(Sender).Canvas.Brush.Color := $00FF80FF;
    Item.ImageIndex := 4;
  end else if not FileExists(Lin2Win(edBasePath.Text, Item.SubItems[0])) then
  begin
    TListView(Sender).Canvas.Brush.Color := $0080FFFF;
    Item.ImageIndex := 5;
  end else
    Item.ImageIndex := 3;
end;

procedure TFormMain.ListViewEdited(Sender: TObject; Item: TListItem;
  var AValue: string);
begin
  if not RenameTitle(Item.SubItems[1], AValue) then
    AValue := Item.Caption;
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

procedure TFormMain.mnLangKorClick(Sender: TObject);
begin
  mnLangKor.Checked := False;
  mnLangEng.Checked := False;
  TMenuItem(Sender).Checked := True;
  Translate(TMenuItem(Sender).Hint);
end;

procedure TFormMain.TreeViewChange(Sender: TObject; Node: TTreeNode);
begin
  if not Assigned(Node) then
    exit;
  if Node.Level = 0 then
    TreeView.ReadOnly := True
  else
    TreeView.ReadOnly := False;
  GetEmuList(Node.Text);
end;

procedure TFormMain.TreeViewDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  i: Integer;
  Node: TTreeNode;
  OldPath, Path, PPath, Filename, Shortname: String;
begin
  if Source is TListView then
  begin
    if not Assigned(TListView(Source).Selected) then
      exit;

    Node := TTreeView(Sender).GetNodeAt(X, Y);

    if Assigned(Node) and not Node.Selected then
    begin
      Node.ImageIndex := 0;
      for i:=ListView.Items.Count-1 downto 0 do
      begin
        if not ListView.Items[i].Selected then
          continue;
        Filename := ExtractFileName(Lin2Win(edBasePath.Text, ListView.Items[i].SubItems[2]));
        Shortname := ListView.Items[i].SubItems[1];
        OldPath := ListView.Items[i].SubItems[2];
        Path := EmuConfig.EmuPath + '/' + edRomPath.Text;
        if Node.Level = 0 then
          PPath := '.'
        else begin
          PPath := Node.Text;
          Path := Path + '/' + PPath;
        end;
        Path := Path + '/' + Filename;

        WriteLog(OldPath + ' --> ' + Path);
        RenameFile(Lin2Win(edBasePath.Text, OldPath), Lin2Win(edBasePath.Text, Path));

        ExecCacheSQL('UPDATE %s_roms SET path = %s, ppath = %s WHERE opinyin = %s',
          [EmuConfig.System, QuotedStr(Path), QuotedStr(PPath), QuotedStr(Shortname)]);

        ListView.BeginUpdate;
        try
          ListView.Items[i].Delete;
        finally
          ListView.EndUpdate;
        end;
      end;
    end;
  end;
end;

procedure TFormMain.TreeViewDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  i: Integer;
  Node: TTreeNode;
begin
  Accept := Source is TListView;
  if Accept then
  begin
    Node := TTreeView(Sender).GetNodeAt(X, Y);

    for i:=0 to TTreeView(Sender).Items.Count-1 do
    begin
      if not TTreeView(Sender).Items[i].Selected then
        TTreeView(Sender).Items[i].ImageIndex := 0;
    end;
    if Assigned(Node) and not Node.Selected then
    begin
      Node.ImageIndex := 2;
    end;
  end;
end;

procedure TFormMain.TreeViewEdited(Sender: TObject; Node: TTreeNode;
  var S: string);
begin
  if not RenameSubDir(Node.Text, S) then
    S := Node.Text
  else
    GetEmuList(S);
end;

procedure TFormMain.AppIdle(Sender: TObject; var Done: Boolean);
begin
  IPCServer.PeekMessage(1, True);
end;

procedure TFormMain.IPCServerMessage(Sender: TObject);
var
  ImageFile, Key: String;
  StrArr: TStringArray;
  i, ImageCount: Integer;
  Count, TotalCount: Integer;
  ImagePath, ImageBase: String;
begin
  IPCServer.ReadMessage;
  if (Copy(IPCServer.StringMessage, 1, 1) = '@') then
  begin
    try
      StrArr := Copy(IPCServer.StringMessage, 2).Split('|');
      ImageFile := StrArr[0];
      ImageBase := Strarr[1];
      Key := StrArr[2];
      ImageCount := StrToInt(StrArr[3]);
      Count := StrToInt(StrArr[4]);
      TotalCount := StrToInt(StrArr[5]);

      if ImageCount > 0 then
      begin
        Image1.Picture.Clear;
        Image2.Picture.Clear;
        Image3.Picture.Clear;
        Image4.Picture.Clear;
      end;

      pbInfo.Visible := TotalCount-Count > 0;
      pbInfo.Max := TotalCount;
      pbInfo.Position := TotalCount - Count;
      pbInfo.Caption := Format('%d / %d', [TotalCount-Count, TotalCount]);
      pbInfo.Hint := pbInfo.Caption;

      EnterCriticalSection(CriticalSection);
      try
        for i:=1 to ImageCount do
        begin
          ImagePath := ExtractFilePath(Application.ExeName) + DirectorySeparator + 'Image' + IntToStr(i) + '.jpg';
          case i of
          1: Image1.Picture.LoadFromFile(ImagePath);
          2: Image2.Picture.LoadFromFile(ImagePath);
          3: Image3.Picture.LoadFromFile(ImagePath);
          4: Image4.Picture.LoadFromFile(ImagePath);
          end;
        end;
      finally
        LeaveCriticalSection(CriticalSection);
      end;
    except
      on E :Exception do
      begin
        WriteLog(E.Message);
        exit;
      end;
    end;

    EnterCriticalSection(CriticalSection);
    try
      if FileExists(ImageFile) then
      begin
        Image.Picture.LoadFromFile(ImageFile);
        Image.Hint := ImageFile;

        for i:=0 to ListView.Items.Count-1 do
          if ListView.Items[i].SubItems[1] = Key then
          begin
            if Copy(edImagePath.Text, 1, 1) = '/' then
              ImageFile := ImageBase + '/' + ExtractFileName(ImageFile)
          else
              ImageFile := EmuConfig.EmuPath + '/' + ImageBase + '/' + ExtractFileName(ImageFile);

            ListView.Items[i].SubItems[0] := ImageFile;
            UpdateCache(Key, 'imgpath', ImageFile);
            break;
          end;
      end;
    finally
      LeaveCriticalSection(CriticalSection);
    end;

    WriteLog(Key + ' (' + pbInfo.Caption + ') - ' + I18N_DONESCRAPE);
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

  if cboEmulator.ItemIndex >= 0 then
    cboEmulator.Tag := cboEmulator.ItemIndex;
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
    if cboEmulator.Items.Count > cboEmulator.Tag then
      cboEmulator.ItemIndex := cboEmulator.Tag
    else
      cboEmulator.ItemIndex := 0;
  end else
    btGenerateCache.Enabled := False;
end;

procedure TFormMain.WriteLog(Log: String);
begin
  mmLog.Lines.Add(Format('[%s] %s', [TimeToStr(Now), Log]));
  mmLog.CaretPos := Point(0, mmLog.Lines.Count-1);
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

      EmuConfig.RomPath := Lin2Win(edBasePath.Text, String(JConfig.GetValue('/rompath' , '../../Roms/' + System)));
      EmuConfig.System := ExtractFileNameOnly(EmuConfig.RomPath);
      EmuConfig.EmuPath := BASE_PATH + '/Emus/' + System;
      EmuConfig.Caption:= String(JConfig.GetValue('/label', ''));
      EmuConfig.Icon   := String(JConfig.GetValue('/icon', ''));
      EmuConfig.CachePath := EmuConfig.RomPath + DirectorySeparator + EmuConfig.System + '_cache7.db';
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

procedure TFormMain.BuildCache(IsDelete: Boolean=False);
var
  Count, AddedCount: Integer;
  ExtList: TStringArray;
  Path: String;

  procedure FindUpdate(SubDir: String; Level: Integer);
  var
    Info: TSearchRec;
    Path, ImgPath, Shortname, Fullname: String;
  begin
    if FindFirst(EmuConfig.RomPath + DirectorySeparator + SubDir + DirectorySeparator + '*' , faAnyFile, Info) = 0 then
    begin
      repeat
        repeat
          if Copy(Info.Name, 1, 1) = '.' then
            break;
          if (Level = 0) and ((Info.Attr and faDirectory) = faDirectory) then
          begin
            FindUpdate(Info.Name, 1);
            break;
          end;

          if (Info.Attr and faDirectory) = faDirectory then
            break;
          ExtList := SplitString(EmuConfig.ExtList, '|');
          if {%H-}MatchStr(Copy(ExtractFileExt(Info.Name), 2), ExtList) then
          begin
            Shortname := ExtractFileNameWithoutExt(ExtractFileName(UTF8String(Info.Name)));
            FullName := GetFullTitle(Shortname, Shortname);
            SQLQuery.SQL.Text := Format('UPDATE %s_roms SET disp = %s WHERE opinyin = %s', [EmuConfig.System, QuotedStr(FullName), QuotedStr(Shortname)]);
            SQLQuery.ExecSQL;
            if SQLQuery.RowsAffected = 0 then
            begin
              Inc(AddedCount);
              Path := EmuConfig.EmuPath + '/' + edRomPath.Text + '/';
              if SubDir = '' then
                SubDir := '.'
              else
                Path := Path + SubDir + '/';
              Path := Path + Shortname + ExtractFileExt(Utf8String(Info.Name));
              if Copy(edImagePath.Text, 1, 1) = '/' then
                ImgPath := edImagePath.Text + '/' + Shortname
              else
                ImgPath := EmuConfig.EmuPath + '/' + edImagePath.Text + '/' + Shortname;
              if FileExists(Lin2Win(edBasePath.Text, ImgPath + '.jpg')) then
                ImgPath := ImgPath + '.jpg'
              else
                ImgPath := ImgPath + '.png';

              SQLQuery.SQL.Text := Format('INSERT INTO %s_roms (disp, path, imgpath, type, ppath, pinyin, cpinyin, opinyin) VALUES (%s, %s, %s, 0, %s, %s, %s, %s)',
                [EmuConfig.System, QuotedStr(Fullname), QuotedStr(Path), QuotedStr(ImgPath), QuotedStr(SubDir), QuotedStr(Fullname), QuotedStr(Fullname), QuotedStr(Shortname)]);
              SQLQuery.ExecSQL;
            end;
          end;

          Inc(Count);

          if Count mod 100 = 0 then
          begin
            WriteLog(I18N_PROCESSING + '... ' + IntToStr(Count));
            Application.ProcessMessages;
          end;
        until True;
      until FindNext(Info) <> 0;

      FindClose(Info);
    end;
  end;

begin
  if IsDelete and FileExists(EmuConfig.CachePath) then
    DeleteFile(EmuConfig.CachePath);

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

    if IsDelete then
    begin
      SQLQuery.SQL.Text := Format('DELETE FROM %s_roms', [EmuConfig.System]);
      SQLQuery.ExecSQL;
    end;
    FindUpdate('', 0);

    Path := EmuConfig.EmuPath + '/' + edRomPath.Text + '/';
    SQLQuery.SQL.Text := Format('INSERT INTO %s_roms (disp, path, imgpath, type, ppath, pinyin, cpinyin, opinyin) SELECT DISTINCT ppath, %s||ppath, %s||ppath, 1, ''.'', '''', '''', '''' FROM %s_roms WHERE ppath <> ''.'' AND ppath NOT IN (SELECT disp FROM %s_roms WHERE type = 1)',
      [EmuConfig.System, QuotedStr(Path), QuotedStr(Path), EmuConfig.System, EmuConfig.System]);
    SQLQuery.ExecSQL;
  finally
    SQLite3Connection.Connected := False;
    WriteLog(IntToStr(AddedCount) + ' - ' + I18N_ADDED);
  end;
end;

procedure TFormMain.GetSubDir;
var
  RootNode: TTreeNode;
  Info: TSearchRec;
begin
  TreeView.BeginUpdate;
  TreeView.Items.Clear;
  try
    RootNode := TreeView.Items.Add(nil, EmuConfig.System);
    RootNode.ImageIndex := 0;
    RootNode.SelectedIndex := 1;

    if FindFirst(EmuConfig.RomPath + DirectorySeparator + '*' , faDirectory, Info) = 0 then
    begin
      repeat
        if (Copy(Info.Name, 1, 1) <> '.')and((Info.Attr and faDirectory) = faDirectory) then
          with TreeView.Items.AddChild(RootNode, Info.Name) do
          begin
            ImageIndex := 0;
            SelectedIndex := 1;
          end;
      until FindNext(Info) <> 0;
    end;

    FindClose(Info);
  finally
    TreeView.EndUpdate;
    TreeView.TopItem.Selected := True;
  end;
end;

procedure TFormMain.GetEmuList(SubDir: String='.');
var
  Title, Shortname: String;
begin
  if not Assigned(TreeView.Selected) or (TreeView.Selected.Level = 0) then
    SubDir := '.';
  ListView.Items.Clear;
  SQLite3Connection.DatabaseName := EmuConfig.CachePath;
  if not SQLite3Connection.Connected then
    SQLite3Connection.Connected := True;

  ListView.BeginUpdate;
  try
    SQLQuery.SQL.Text := Format('SELECT id, disp, path, imgpath, pinyin, opinyin FROM %s_roms WHERE ppath = %s AND type = 0', [EmuConfig.System, QuotedStr(SubDir)]);
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
        ImageIndex := 3;
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
  if (Key = Tobe) or (Tobe = '') then
    exit;

  Result := UpdateCache(Key, 'disp', Tobe);
  if Result then
    Result := UpdateRomName(Key, Tobe);
end;

function TFormMain.RenameSubDir(Asis, Tobe: String): Boolean;
var
  TobePath, AsisPath: String;
begin
  if (Asis = Tobe) or (Tobe = '') then
  begin
    Result := False;
    exit;
  end;

  AsisPath := '/' + edRomPath.Text + '/' + Asis + '/';
  TobePath := '/' + edRomPath.Text + '/' + Tobe + '/';

  RenameFile(Lin2Win(edBasePath.Text, AsisPath), Lin2Win(edBasePath.Text, TobePath));
  Result := ExecCacheSQL('UPDATE %s_roms SET path = REPLACE(path, %s, %s), ppath = %s WHERE ppath = %s',
        [EmuConfig.System, QuotedStr(AsIsPath), QuotedStr(TobePath), QuotedStr(Tobe), QuotedStr(Asis)]);
  if Result then
    Result := ExecCacheSQL('UPDATE %s_roms SET disp = %s WHERE disp = %s AND type = 1',
        [EmuConfig.System, QuotedStr(Tobe), QuotedStr(Asis)]);
end;

function TFormMain.DeleteSubDir: Boolean;
var
  Dir: String;
begin
  Result := False;
  if Application.MessageBox(PChar(I18N_DELETEDIRCONFIRM),
    PChar(I18N_CONFIRM), MB_ICONQUESTION + MB_YESNO) <> IDYES then
    exit;
  if Assigned(TreeView.Selected) then
  begin
    if TreeView.Selected.Level = 0 then
      exit;

    Dir := Lin2Win(edBasePath.Text, EmuConfig.EmuPath + '/' + edRomPath.Text + '/' + TreeView.Selected.Text);

    if not DirectoryExists(Dir) then
      WriteLog(I18N_DIRNOTFOUND + ' - ' + Dir)
    else if not DeleteDirectory(Dir, False) then
    begin
      WriteLog(I18N_ERROROCCURED + ' - ' + Dir);
      exit;
    end;
  end;

  Result := ExecCacheSQL('DELETE FROM %s_roms WHERE ppath = %s AND type = 0', [EmuConfig.System, QuotedStr(TreeView.Selected.Text)]);
  if Result then
    Result := ExecCacheSQL('DELETE FROM %s_roms WHERE disp = %s AND type = 1', [EmuConfig.System, QuotedStr(TreeView.Selected.Text)]);

  if Result then
  begin
    TreeView.Selected.Delete;
    TreeView.TopItem.Selected := True;
  end;
end;

function TFormMain.ExecCacheSQL(Query: String; Args: array of const): Boolean;
begin
  Result := False;
  if (Query = '') then
    exit;

  if not SQLite3Connection.Connected then
    SQLite3Connection.Connected := True;
  try
    SQLQuery.SQL.Text := Format(Query, Args);
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
  finally
    SQLite3Connection.Connected := False;
  end;
end;

function TFormMain.InsertCache(Filename: String; SubDir: String=''): String;
var
  Path, ImgPath, Shortname, Fullname: String;
begin
  SQLite3Connection.DatabaseName := EmuConfig.CachePath;
  if not SQLite3Connection.Connected then
    SQLite3Connection.Connected := True;

  WriteLog(EmuConfig.System + ' - ' + I18N_GENCACHE);

  if not Assigned(TreeView.Selected) or (TreeView.Selected.Level = 0) then
    SubDir := '';

  try
    SQLQuery.SQL.Text :=
      Format('CREATE TABLE IF NOT EXISTS %s_roms (id INTEGER NOT NULL, disp TEXT NOT NULL,	path TEXT NOT NULL,	imgpath TEXT NOT NULL, type INTEGER NULL, ppath TEXT NOT NULL, pinyin TEXT NOT NULL, cpinyin TEXT NOT NULL, opinyin TEXT NOT NULL,	PRIMARY KEY (id))',
      [EmuConfig.System]);
    SQLQuery.ExecSQL;

    Shortname := ExtractFileNameWithoutExt(ExtractFilename(Filename));
    Fullname := GetFullTitle(Shortname, Shortname);
    Result := Fullname;
    Path := EmuConfig.EmuPath + '/' + edRomPath.Text;
    if SubDir = '' then
      SubDir := '.'
    else
      Path := Path + '/' + SubDir;
    Path := Path + '/' + Filename;
    SQLQuery.SQL.Text := Format('UPDATE %s_roms SET disp = %s, path = %s WHERE opinyin = %s', [EmuConfig.System, QuotedStr(FullName), QuotedStr(Path), QuotedStr(Shortname)]);
    SQLQuery.ExecSQL;
    if SQLQuery.RowsAffected = 0 then
    begin
      if Copy(edImagePath.Text, 1, 1) = '/' then
        ImgPath := edImagePath.Text + '/' + ExtractFileNameWithoutExt(FileName) + '.png'
      else
        ImgPath := EmuConfig.EmuPath + '/' + edImagePath.Text + '/' + Shortname + '.png';
      SQLQuery.SQL.Text := Format('INSERT INTO %s_roms (disp, path, imgpath, type, ppath, pinyin, cpinyin, opinyin) VALUES (%s, %s, %s, 0, %s, %s, %s, %s)',
        [EmuConfig.System, QuotedStr(Fullname), QuotedStr(Path), QuotedStr(ImgPath), QuotedStr(SubDir), QuotedStr(Fullname), QuotedStr(Fullname), QuotedStr(Shortname)]);
      SQLQuery.ExecSQL;
    end;
  finally
    SQLite3Connection.Connected := False;
    WriteLog(Filename + ' - ' + I18N_ADDED);
  end;
end;

function TFormMain.UpdateCache(Key, Column, Value: String): Boolean;
begin
  Result := ExecCacheSQL('UPDATE %s_roms SET %s = %s WHERE opinyin = %s',
    [EmuConfig.System, Column, QuotedStr(Value), QuotedStr(Key)]);
end;

function TFormMain.DeleteCache(Key: String): Boolean;
begin
  Result := ExecCacheSQL('DELETE FROM %s_roms WHERE opinyin = %s', [EmuConfig.System, QuotedStr(Key)]);
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

procedure TFormMain.GenCacheFromXml(Gamelist: String);
var
  RootNode, Node, ChildNode: TDOMNode;
  Xml: TXMLDocument;
  disp, path, imgpath, ppath, yin: String;
  tp: Integer;
  i: Integer;
begin
  SQLite3Connection.DatabaseName := EmuConfig.CachePath;
  if not ExecCacheSQL('DELETE FROM %s_roms', [EmuConfig.System]) then
  begin
    WriteLog(I18N_ERROROCCURED + ' - ' + 'DELETE FROM clause');
    exit;
  end;

  ReadXMLFile(Xml, gamelist);
  try
    RootNode := Xml.FindNode('gameList');
    if RootNode = nil then
    begin
      WriteLog('gameList tag not found - ' + gamelist);
      exit;
    end;

    pbInfo.Max := RootNode.GetChildNodes.Count;
    pbInfo.Visible := True;
    imgpath := '';
    for i:= 0 to RootNode.GetChildNodes.Count-1 do
    begin
      tp := Ord(RootNode.GetChildNodes.Item[i].NodeName = 'folder');
      Node := RootNode.GetChildNodes.Item[i];
      ChildNode := Node.FindNode('name');
      disp := AnsiString(ChildNode.TextContent);
      ChildNode := Node.FindNode('image');
      imgpath := AnsiString(ChildNode.TextContent);

      if tp = 0 then
      begin
        ChildNode := Node.FindNode('path');
        path := AnsiString(ChildNode.TextContent);

        ppath := ExtractFileNameOnly(ExtractFileDir(path));
        if (EmuConfig.System = ppath) or (ppath= '') or (ppath = '.') or (ppath = '/.') then
          ppath := '.';

        yin := disp;
      end else
      begin
        path := edRomPath.Text;
        ppath := '.';
        yin := '';
      end;

      if not ExecCacheSQL('INSERT INTO %s_roms (disp, path, imgpath, type, ppath, pinyin, cpinyin, opinyin) VALUES (%s, %s, %s, %d, %s, %s, %s, %s)',
              [EmuConfig.System, QuotedStr(disp), QuotedStr(path), QuotedStr(imgpath), tp, QuotedStr(ppath), QuotedStr(yin), QuotedStr(yin), QuotedStr(yin)]) then
      begin
        WriteLog(I18N_ERROROCCURED + ' - ' + 'INSERT INTO clause - ' + disp);
        exit;
      end;

      pbInfo.Position := i+1;
      if pbInfo.Position mod 10 = 0 then
        Application.ProcessMessages;
    end;

    WriteLog(I18N_DONE + ' - ' + Gamelist);
    cboEmulatorChange(cboEmulator);
  finally
    Xml.Free;
  end;
end;

procedure TFormMain.ReadSettings;
var
  IniFile, Lang: String;
begin
  IniFile := ExtractFilePath(Application.ExeName) +
    ExtractFileNameOnly(Application.ExeName) + '.ini';
  with TIniFile.Create(IniFile) do
  try
    Lang := ReadString('Main', 'Lang', 'EN');
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
