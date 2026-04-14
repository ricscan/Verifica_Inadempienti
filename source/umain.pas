unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, DB, memds, Forms, Controls, Graphics,
  Dialogs, Menus, ComCtrls, ExtCtrls, StdCtrls, DBGrids, MaskEdit, RTTICtrls,
  SpinEx, uClsVerInad;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnInserisci: TButton;
    BtnElimina: TButton;
    Button1: TButton;
    BtnAggiorna: TButton;
    CBTipoSoggetto: TComboBox;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Edit1: TEdit;
    Edit2: TEdit;
    EditCodiceFiscale: TEdit;
    EditFileAnno: TEdit;
    EditFileProgressivo: TEdit;
    EditFootDataFile: TEdit;
    EditFootIdFile: TEdit;
    EditFootNumRec: TEdit;
    EditFootProgRec: TEdit;
    EditFootTipoRec: TEdit;
    EditHeadDataFile: TEdit;
    EditHeadeProgRec: TEdit;
    EditHeadIdFile: TEdit;
    EditHeadRelease: TEdit;
    EditNomeFilePath: TEdit;
    EditNomeFile: TEdit;
    EditNominativo: TEdit;
    EditIDPagamento: TEdit;
    EditImporto: TEdit;
    EditTipoRec: TEdit;
    FloatSpinEditEx1: TFloatSpinEditEx;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ListView1: TListView;
    MainMenu1: TMainMenu;
    MaskEdit1: TMaskEdit;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    SaveDialog1: TSaveDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    Separator1: TMenuItem;
    SQLite3Connection1: TSQLite3Connection;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    StatusBar1: TStatusBar;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    procedure BtnEliminaClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure EditFileAnnoChange(Sender: TObject);
    procedure EditFileProgressivoChange(Sender: TObject);
    procedure FloatSpinEditEx1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
    procedure MaskEdit1Change(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);

  private
    CVerInad :TCVerInad;
    FAnagraficaCache: TStringList;
    Procedure CaricaAnagraficaInCache;
    Procedure AggiornaNomeFileIRM;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.MenuItem2Click(Sender: TObject);
var
  t:integer;
  e:TListItem;
  HeadStr:String;
  FootStr:String;
  tmps  :String;
  NomeFile,NomeFilePath:String;
  TipoSoggetto:String;
  Nominativo,ImportoS:String;
  CF:STring;

  Ben:TClsVerInadBeneficiario;
begin
  ListView1.Clear;

  if Opendialog1.Execute then
  begin

    DecimalSeparator := ',';
    ThousandSeparator := '.';

    NomeFilePath:=Opendialog1.Filename;
    NomeFile:=ExtractFileName(NomeFilePath);
    EditNomeFilePath.Text:=NomeFilePath;
    EditFileAnno.Text:=Copy(NomeFile,7,4);
    EditFileProgressivo.Text:=IntToStr(StrToInt(Copy(NomeFile,11,10)));

    Form1.Caption:='Verifica Inadempienze 1.0 -'+NomeFile;

    CVerInad.Load(Opendialog1.FileName);

    EditTipoRec.Text        :=CVerInad.Head.TipoRecord;
    EditHeadeProgRec.Text   :=IntToStr(CVerInad.Head.ProgressivoRecord);
    EditHeadIdFile.Text     :=CVerInad.Head.IDFile;
    EditHeadDataFile.Text   := DateToStr(CVerInad.Head.DataFile);
    EditHeadRelease.Text    := CVerInad.head.Release;

    Memo1.Text:=CVerInad.SL.Text;
    ListView1.Items.BeginUpdate;

    try
      for Ben in CVerInad.Beneficiari.Lista do
      begin
       e:=ListView1.Items.add;
      //Ben:=TClsVerInadBeneficiario(CVerInad.Beneficiari.Lista[T]);
      //Ben:=CVerInad.Beneficiari.Lista[t];

      e.Caption := Ben.A_TipoRecord;
      e.SubItems.Add(IntToStr(Ben.B_ProgressivoRecord));
      e.SubItems.Add(IntToStr(Ben.C_ProgressivoRichiesta));
      case Ben.D_TipoSoggetto of
           1:TipoSoggetto:='1 - Pers.Fisica';
           2:TipoSoggetto:='2 - Pers.Giuridica';
      else
         TipoSoggetto:=IntToStr(Ben.D_TipoSoggetto)
      end;
      e.SubItems.Add(TipoSoggetto);

      e.SubItems.Add(Ben.E_CodiceFiscale);
      CF:= Ben.E_CodiceFiscale;

      Ben.EE_Nominativo := FAnagraficaCache.Values[CF];
      if Ben.EE_Nominativo = '' then Ben.EE_Nominativo := '-non trovato-';

      e.SubItems.Add(Ben.EE_Nominativo);
      e.SubItems.Add(Ben.F_IDPagamento);
      e.SubItems.Add(FormatCurr('#,##0.00',Ben.G_ImportoPagamento));
      e.Data:=Ben;
      end;

    finally
      ListView1.Items.EndUpdate;
    end;


 //   for t:=0 to CVerInad.Beneficiari.Lista.Count-1
//    do begin

//    end;


     EditFootTipoRec.text := CVerInad.Foot.TipoRecord;
     EditFootProgRec.text := IntToStr(CVerInad.Foot.ProgressivoRecord);
     EditFootIdFile.text  := CVerInad.Foot.IDFile;
     EditFootDataFile.Text:= DateToStr(CVerInad.Foot.DataFile);
     EditFootNumRec.Text  := IntToStr(CVerInad.Foot.NumeroRecord);
    end;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  CVerInad :=TCVerInad.Create;

  // Inizializzazione Cache Anagrafica
  FAnagraficaCache := TStringList.Create;
  FAnagraficaCache.Sorted := True; // Indispensabile per ricerche veloci
  FAnagraficaCache.Duplicates := dupIgnore; // Evita errori in caso di CF duplicati nel DB

  // Caricamento iniziale dei dati dal DB alla memoria
  CaricaAnagraficaInCache;
end;

procedure TForm1.Label2Click(Sender: TObject);
begin

end;

procedure TForm1.ListView1Click(Sender: TObject);
var
  i:Integer;
  Beneficiario : TClsVerInadBeneficiario;
begin
  i:=ListView1.ItemIndex;
  if i=-1 then exit;
  Beneficiario := CVerInad.Beneficiari.Item(i);
  CBTipoSoggetto.ItemIndex :=Beneficiario.D_TipoSoggetto;
  EditCodiceFiscale.Text   :=Beneficiario.E_CodiceFiscale;
  EditNominativo.Text      :=Beneficiario.EE_Nominativo;
  EditIDPagamento.Text     :=Beneficiario.F_IDPagamento;
  EditImporto.Text         :=FormatCurr('#,##0.00',Beneficiario.G_ImportoPagamento)
end;

procedure TForm1.MaskEdit1Change(Sender: TObject);
begin

end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CVerInad.free;
  FAnagraficaCache.free;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Sqlite3Connection1.Connected:=True;
  SqlQuery1.Close;
  SqlQuery1.SQL.Text:='Select * from Persone';
  SqlQuery1.Open;
end;

procedure TForm1.EditFileAnnoChange(Sender: TObject);
begin
  AggiornaNomeFileIRM;
end;

procedure TForm1.EditFileProgressivoChange(Sender: TObject);
begin
  AggiornaNomeFileIRM;
end;

procedure TForm1.BtnEliminaClick(Sender: TObject);
var
  i: Integer;
  Ben: TClsVerInadBeneficiario;
begin
  // 1. Recuperiamo l'indice dell'elemento selezionato
  i := ListView1.ItemIndex;

  // Controllo di sicurezza: se nulla è selezionato, usciamo
  if i = -1 then
  begin
    ShowMessage('Seleziona un beneficiario da eliminare.');
    Exit;
  end;

  // Conferma dell'utente (opzionale ma consigliata)
  if MessageDlg('Conferma', 'Vuoi eliminare il beneficiario selezionato?',
    mtConfirmation, [mbYes, mbNo], 0) = mrNo then Exit;

  // 2. Rimozione dalla logica di business (Lista Generics)
  // Grazie a TObjectList.Create(True), l'oggetto viene rimosso e distrutto automaticamente
  //CVerInad.Beneficiari.Lista.Delete(i);

  // 3. Rimozione dalla visualizzazione grafica
  //ListView1.Items.Delete(i);
  Ben := TClsVerInadBeneficiario(ListView1.Selected.Data);
  CVerInad.Beneficiari.Lista.Remove(Ben);
  ListView1.Selected.delete;

  // 4. Aggiornamento del Footer e dell'interfaccia
  // Poiché il numero totale di record è cambiato, aggiorniamo il contatore nel Footer
  CVerInad.Foot.NumeroRecord := CVerInad.Beneficiari.Count;
  EditFootNumRec.Text := IntToStr(CVerInad.Foot.NumeroRecord);

  // Puliamo i campi di editing per evitare confusione
  CBTipoSoggetto.ItemIndex := -1;
  EditCodiceFiscale.Clear;
  EditNominativo.Clear;
  EditIDPagamento.Clear;
  EditImporto.Clear;

  StatusBar1.SimpleText := 'Beneficiario eliminato. Ricordati di salvare il file.';
end;

procedure TForm1.FloatSpinEditEx1Change(Sender: TObject);
begin

end;

{procedure TForm1.MenuItem3Click(Sender: TObject);
var
  nFile:String;
begin
  Savedialog1.FileName:=CVerInad.NomeFileIRM+'.txt';
  if Savedialog1.Execute then
  begin
    nFile:=Savedialog1.Filename;
    CVerInad.Save(nFile);
    ShowMessage('File Salvato');
  end;
end; }
procedure TForm1.MenuItem3Click(Sender: TObject);
var
  NomeFileObbligatorio: string;
  PercorsoCompleto: string;
begin
  // 1. Generiamo il nome file (senza estensione) usando la funzione helper
  // Assicurati che EditFileAnno e EditFileProgressivo siano popolati
  NomeFileObbligatorio := CVerInad.NomeFileIRM;

  // 2. Apriamo il dialogo per scegliere la CARTELLA
  if SelectDirectoryDialog1.Execute then
  begin
    // 3. Componiamo il percorso: Cartella Scelta + Nome Generato + .txt
    // IncludeTrailingPathDelimiter aggiunge la slash (\) se manca
    PercorsoCompleto := IncludeTrailingPathDelimiter(SelectDirectoryDialog1.FileName) +
                        NomeFileObbligatorio + '.txt';

    // 4. Controllo sicurezza: se il file esiste già, chiediamo conferma
    if FileExists(PercorsoCompleto) then
    begin
      if MessageDlg('Attenzione', 'Il file ' + NomeFileObbligatorio +
         ' esiste già. Sovrascriverlo?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
         Exit;
    end;

    // 5. Eseguiamo il salvataggio
    // La nostra TCVerInad.Save userà il nome per RMA e RMZ
    CVerInad.Save(PercorsoCompleto);

    // 6. Feedback all'utente
    StatusBar1.SimpleText := 'File salvato in: ' + PercorsoCompleto;
    ShowMessage('File ' + NomeFileObbligatorio + '.txt generato con successo.');
  end;
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  close;
end;

procedure TForm1.MenuItem6Click(Sender: TObject);
begin

end;

procedure TForm1.MenuItem8Click(Sender: TObject);
var
  CSVFile: TextFile;
  Riga, CF, Nominativo: string;
  PosSeparatore: Integer;
begin
  if not OpenDialog1.Execute then
    Exit;

  // Assicuriamoci che la connessione sia attiva
  try
    if not SQLite3Connection1.Connected then
      SQLite3Connection1.Connected := True;

    // 1. Prepariamo la query con i parametri invece di concatenare le stringhe
    // L'uso di INSERT OR IGNORE evita errori in caso di duplicati sulla Primary Key (CF)
    SQLQuery1.Close;
    SQLQuery1.SQL.Text := 'INSERT OR IGNORE INTO Persone (CF, Nominativo) VALUES (:cf, :nom);';

    // Iniziamo la transazione: SQLite è incredibilmente più veloce se esegui
    // molte insert all'interno di un'unica transazione esplicita.
    SQLTransaction1.Active := True;

    AssignFile(CSVFile, OpenDialog1.FileName);
    Reset(CSVFile);

    try
      while not Eof(CSVFile) do
      begin
        ReadLn(CSVFile, Riga);
        // Supponiamo che il separatore sia il punto e virgola ';'
        PosSeparatore := Pos(';', Riga);

        if PosSeparatore > 0 then
        begin
          CF := Trim(Copy(Riga, 1, PosSeparatore - 1)).ToUpper;
          Nominativo := Trim(Copy(Riga, PosSeparatore + 1, Length(Riga)));

          if (CF <> '') then
          begin
            // 2. Assegnazione dei parametri (Sicurezza contro SQL Injection)
            SQLQuery1.Params.ParamByName('cf').AsString := CF;
            SQLQuery1.Params.ParamByName('nom').AsString := Nominativo;
            SQLQuery1.ExecSQL;
          end;
        end;
      end;

      // 3. Confermiamo tutte le modifiche in un colpo solo
      SQLTransaction1.Commit;
      ShowMessage('Importazione completata con successo.');

      // Opzionale: ricarica la cache se la stai usando per la visualizzazione
      // CaricaAnagraficaInCache;

    except
      on E: Exception do
      begin
        // In caso di errore, annulliamo tutto per mantenere l'integrità del DB
        SQLTransaction1.Rollback;
        ShowMessage('Errore durante l''importazione: ' + E.Message);
      end;
    end;

  finally
    CloseFile(CSVFile);
  end;
end;

{procedure TForm1.MenuItem8Click(Sender: TObject);

var
  Conn: TSQLite3Connection;
  Tran: TSQLTransaction;
  FileName:String;
  CSVFile: TextFile;
  Riga, CF, Nominativo: string;
  PosSeparatore: Integer;

begin
  If Opendialog1.Execute then
  begin
  FileName :=Opendialog1.FileName;
  //Classes, SysUtils, sqlite3conn, sqldb, db;

  // 1. Configurazione Connessione e Transazione

    //Conn.DatabaseName := 'anagrafica.db';
    //Conn.Transaction := Tran;
    Conn:=Sqlite3Connection1;
    Tran:=SQLTransaction1;
    Conn.Open;
    Tran.Active := True;

    // 2. Creazione Tabella con Chiave Primaria (per evitare duplicati)
    Conn.ExecuteDirect('CREATE TABLE IF NOT EXISTS Persone (' +
                       'codice_fiscale TEXT PRIMARY KEY, ' +
                       'nominativo TEXT);');

    // 3. Apertura File CSV
    if not FileExists(FileName) then
    begin
      ShowMessage('Errore: File dati.csv non trovato.');
      Exit;
    end;

    AssignFile(CSVFile, FileName);
    Reset(CSVFile);

    ShowMessage('Inizio importazione...');

    while not Eof(CSVFile) do
    begin
      ReadLn(CSVFile, Riga);
      // Supponiamo che il separatore sia la virgola
      PosSeparatore := Pos(';', Riga);

      if PosSeparatore > 0 then
      begin
        CF := Trim(Copy(Riga, 1, PosSeparatore - 1)).ToUpper;
        Nominativo := Trim(Copy(Riga, PosSeparatore + 1, Length(Riga)));

        // 4. Inserimento con clausola OR IGNORE
        // Usiamo i parametri per evitare SQL Injection e gestire apici nel nome
        Conn.ExecuteDirect('INSERT OR IGNORE INTO Persone (CF,Nominativo) ' +
                           'VALUES (' + QuotedStr(CF) + ', ' + QuotedStr(Nominativo) + ');');
      end;
    end;

    CloseFile(CSVFile);
    Tran.Commit;
    ShowMessage('Importazione completata con successo.');

{  except
    on E: Exception do
    begin
      Tran.Rollback;
      ShowMessage('Errore durante l''importazione: ', E.Message);
    end;
  end;
}

//  Tran.Free;
//  Conn.Free;

  end;
end;
}

procedure TForm1.PageControl1Change(Sender: TObject);
begin

end;

procedure TForm1.CaricaAnagraficaInCache;
begin
  FAnagraficaCache.Clear;
    SqlQuery1.Close;
    SqlQuery1.SQL.Text := 'SELECT CF, Nominativo FROM Persone';
    SqlQuery1.Open;

    while not SqlQuery1.Eof do
    begin
      FAnagraficaCache.AddPair(
        SqlQuery1.FieldByName('CF').AsString.ToUpper,
        SqlQuery1.FieldByName('Nominativo').AsString
      );
      SqlQuery1.Next;
    end;
end;

procedure TForm1.AggiornaNomeFileIRM;
begin
  EditNomeFile.Text:=CVerInad.GeneraNomeFileIRM(EditFileAnno.Text,EditFileProgressivo.Text);
  EditHeadIDFile.text:=CVerInad.Head.IDFile;
  EditFootIDFile.text:=CVerINAD.Foot.IDFile;
end;


end.

