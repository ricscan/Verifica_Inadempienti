unit uClsVerInad;

{$mode ObjFPC}{$H+}
//{$mode delphi}
interface

uses
  Classes, SysUtils,Generics.Collections;//Contnrs;

type
  IDFile=record  //Identificativo FILE
    A :array[1..3] of char; //Assume valore 'IRM'
    B :array[1..3] of char; //Codice equitalia Servizi 'EQS'
    C :array[1..4] of char; //Anno
    D :array[1..10] of char; //Progressivo
  end;

  TRMA=record   //record di Testa lunghezza 300 Caratteri
    A :array[1..3] of char; //vale sempre 'RMA'
    B :array[1..7] of char; //Progressivo record vale sempre '0000001'
    C :array[1..20] of char; // Identificativo File
    D :array[1..8] of char; //Data Creazione File espressa AAAAMMGG
    E :array[1..3] of char;  //Release,assume valore 'R01'
    F :array[1..259] of char; //Filler spazi
  end;

  TRMD=record
    A :array[1..3] of char; //vale sempre 'RMD'
    B :array[1..7] of char; //Progressivo record +1 PRECEDENTE
    C :array[1..7] of char; //Progressivo richiesta vale 0000001
    D :array[1..1] of char; //Tipo Soggetto: 1:persona fisica, 2:persona Giuridica
    E :array[1..16] of char; //Cod.Fiscale Beneficiario
    F :array[1..15] of char; //Identificativo del pagamento
    G :array[1..15] of char; //Importo del titolo da pagare
    H :array[1..35] of char; //Indirizzo Beneficiario : deve essere blank
    I :array[1..5] of char; //Numero Civico Beneficiario : deve essere Blank
    J :array[1..5] of char; //CAP Beneficiario; deve essere blank
    K :array[1..2] of char; //Sigle Provincia Beneficiario; deve essere blank
    L :array[1..50] of char; //Descrizione comune beneficiario; deve essere blank
    M :array[1..12] of char; //Num.Tel. Beneficiario; non obbligatorio
    N :array[1..35] of char; //Cognome referente beneficiario; non obbligatorio
    O :array[1..35] of char; //Nome referente Beneficiario;
    P :array[1..57] of char; //Filler
  end;

  TRMZ=record
    A :array[1..3] of char; //vale sempre 'RMZ'
    B :array[1..7] of char; //Progressivo record +1 PRECEDENTE
    C :array[1..20] of char; // Identificativo File uguale al record di testa
    D :array[1..8] of char; //Data Creazione File espressa AAAAMMGG
    E :array[1..7] of char; //Numero Totale Record;
    F :array[1..255] of char; //Filler Spazi
  end;

  { TClsVerInadBeneficiario }

  TClsVerInadBeneficiario=Class
    A_TipoRecord            :String[3]; //RMD
    B_ProgressivoRecord     :Integer;
    C_ProgressivoRichiesta  :Integer;
    D_TipoSoggetto          :Integer;  //1 - 2
    E_CodiceFiscale         :String[16];
    EE_Nominativo           :String;
    F_IDPagamento           :String[15];
    G_ImportoPagamento      :Currency;
    H_IndirizzoBeneficiario :String[35];
    I_NumeroCivicoBen       :string[5];
    J_CapBeneficiario       :String[5];
    K_SiglaProvincia        :String[2];
    L_DescrComuneBen        :String[50];
    M_NumTelBen             :String[12];
    N_CognomeRefBen         :string[35];
    O_NomeRefBen            :String[35];
    P_Filler                :String[57];
    Constructor Create;
    Destructor Destroy;
    Procedure Load(Tmps:String);
    Function Save:STring;
  end;


  // Definiamo un alias per comodità
  TBeneficiariList = specialize TObjectList<TClsVerInadBeneficiario>;
  //TBeneficiariList = TObjectList<TClsVerInadBeneficiario>;

  { TClsVerInadListBeneficiario }

  TClsVerInadListBeneficiario=Class
    //Lista:TObjectList;
    Lista: TBeneficiariList;

    Constructor Create;
    Destructor Destroy;override;
    Procedure Insert(Tmps:String);
    function Item(i:Integer):TClsVerInadBeneficiario;
    Function Count:Integer;
  end;

  { TClsVerInadHead }

  TClsVerInadHead=Class
    TipoRecord         :String[3]; //RMA
    ProgressivoRecord  :Integer;
    IDFile             :String[20];
    DataFile           :TDate;
    Release            :String[3]; //R01
    Filler             :String;//[259]
    Constructor Create;
    Destructor Destroy;override;
    Procedure Load(Tmps:String);
    Function Save:STring;
  end;

  { TClsVerInadFoot }

  TClsVerInadFoot=Class
    TipoRecord         :String[3]; //RMZ
    ProgressivoRecord  :Integer;
    IDFile             :String[20];
    DataFile           :TDate;
    NumeroRecord       :Integer;
    Filler             :String[255];
    Constructor Create;
    Destructor Destroy;override;
    Procedure Load(Tmps:String);
    Function Save:STring;
  end;

type

  { TCVerInad }

  TCVerInad = class
    FileName:string;
    NomeFileIRM:String;
//    RMA:TRMA;
//    ARRRMD:array of TRMD;
//    RMZ:TRMZ;

    Head :TClsVerInadHead;
    Beneficiari :TClsVerInadListBeneficiario;
    Foot :TClsVerInadFoot;

    nCount:Integer;
    SL:TstringList;
    Constructor Create;
    Destructor Destroy;override;
    procedure Load(aFilename:String);
    procedure Save(aFilename:String);
    function GeneraNomeFileIRM(Anno: string; Progressivo: string): string;
  end;

implementation

function YYYYMMDDToDate(const sDate: string): TDateTime;
var
  Year, Month, Day: Word;
begin
  if Length(sDate) <> 8 then
    raise Exception.Create('Formato data non valido: usare YYYYMMDD');

  // Estrazione delle parti
  Year  := StrToInt(Copy(sDate, 1, 4));
  Month := StrToInt(Copy(sDate, 5, 2));
  Day   := StrToInt(Copy(sDate, 7, 2));

  // Conversione in TDateTime
  Result := EncodeDate(Year, Month, Day);
end;

Function DateToYYYYMMDD(Data: TDate):string;
var
  Anno, Mese, Giorno: Word;
begin
  // Scompone la data in anno, mese e giorno
  DecodeDate(Data, Anno, Mese, Giorno);

  // Formatta i valori in una stringa YYYYMMDD
  // %d = intero, %.4d = intero di almeno 4 cifre, %.2d = almeno 2 cifre
  DateToYYYYMMDD := Format('%.4d%.2d%.2d', [Anno, Mese, Giorno]);
end;

function RiempiFinoA(S: string; X: Char; n: Integer): string;
var
  i, Mancanti: Integer;
begin
  Result := S;
  Mancanti := n - Length(S);

  // Aggiunge caratteri solo se la lunghezza attuale è inferiore a n
  for i := 1 to Mancanti do
    Result := Result + X;
end;

function IntToZeroPadded(X: Integer; n: Integer): string;
begin
  // '%.*d' dice a Pascal di usare il primo parametro (n) come larghezza minima
  Result := Format('%.*d', [n, X]);
end;

{ TClsVerInadBeneficiario }

constructor TClsVerInadBeneficiario.Create;
begin

end;

destructor TClsVerInadBeneficiario.Destroy;
begin

end;

procedure TClsVerInadBeneficiario.Load(Tmps: String);
var
  Importo,i:Integer;
  ImportoC:double;
begin
  A_TipoRecord            :=Copy(Tmps,1,3);
  B_ProgressivoRecord     :=StrToInt(Copy(Tmps,4,7));
  C_ProgressivoRichiesta  :=StrToInt(Copy(Tmps,11,7));
  D_TipoSoggetto          :=StrToInt(Copy(Tmps,18,1));
  E_CodiceFiscale         :=Copy(Tmps,19,16);
  //EE_Nominativo           :=CercaNominativo(E_CodiceFiscale);
  F_IDPagamento           :=Copy(Tmps,35,15);
  val(Copy(tmps,50,15),Importo,I);

  G_ImportoPagamento      :=Importo/100;
  H_IndirizzoBeneficiario :='';//String[35];
  I_NumeroCivicoBen       :='';//string[5];
  J_CapBeneficiario       :='';//String[5];
  K_SiglaProvincia        :='';//String[2];
  L_DescrComuneBen        :='';//String[50];
  M_NumTelBen             :='';//String[12];
  N_CognomeRefBen         :='';//string[35];
  O_NomeRefBen            :='';//String[35];
  P_Filler                :='';//String[57];
end;

function TClsVerInadBeneficiario.Save: STring;
var
  StrOut,Tmps:String;
  StrTipoRecord :String;
  StrProgressivoRecord:String;
  StrProgressivoRichiesta:String;
  StrTipoSoggetto:String;
  StrCodiceFiscale:String;
  StrIDPagamento:String;
  StrImportoPagamento:String;
  ImportoPag :Integer;
begin
  StrTipoRecord               :='RMD';
  StrProgressivoRecord        :=IntToZeroPadded(B_ProgressivoRecord,7);
  StrProgressivoRichiesta     :=IntToZeroPadded(C_ProgressivoRichiesta,7);
  StrTipoSoggetto             :=IntToStr(D_TipoSoggetto);
  StrCodiceFiscale            :=E_CodiceFiscale;
  StrIDPagamento              :=RiempiFinoA(F_IDPagamento,' ',15);
  ImportoPag:=round(G_ImportoPagamento*100);
  StrImportoPagamento         :=IntToZeroPadded(ImportoPag,15);

  StrOut:=StrTipoRecord+StrProgressivoRecord+StrProgressivoRichiesta+StrTipoSoggetto
  +StrCodiceFiscale+StrIDPagamento+StrImportoPagamento;
  StrOut:=RiempiFinoA(StrOut,' ',300);
  Save:=StrOut;
end;

{ TClsVerInadListBeneficiario }

constructor TClsVerInadListBeneficiario.Create;
begin

  //Lista:=TObjectList.Create(True);
  Lista := TBeneficiariList.Create(True);  //True Libera gli oggetti
end;

destructor TClsVerInadListBeneficiario.Destroy;
begin
  Lista.free;
  inherited Destroy;
end;

procedure TClsVerInadListBeneficiario.Insert(Tmps: String);
var Beneficiario:TClsVerInadBeneficiario;
begin
  Beneficiario:=TClsVerInadBeneficiario.Create;
  Beneficiario.Load(Tmps);
  Lista.add(Beneficiario);
end;

function TClsVerInadListBeneficiario.Item(i: Integer): TClsVerInadBeneficiario;
begin
  //Item:=TClsVerInadBeneficiario(Lista[i]);
  Result:=Lista[i];
end;

function TClsVerInadListBeneficiario.Count: Integer;
begin
  Count:=Lista.Count;
end;

{ TClsVerInadHead }

constructor TClsVerInadHead.Create;
begin

end;

destructor TClsVerInadHead.Destroy;
begin

end;

procedure TClsVerInadHead.Load(Tmps: String);
begin
  TipoRecord         :=Copy(Tmps,1,3); //RMA
  ProgressivoRecord  :=StrToInt(Copy(Tmps,4,7));
  IDFile             :=Copy(Tmps,11,20);
  DataFile           :=YYYYMMDDToDate(Copy(Tmps,31,8));
  Release            :=Copy(Tmps,39,3); //R01
//  Filler             :String;//[259]
end;

//ricostruisce il record di testa
function TClsVerInadHead.Save: STring;
var
  StrOut:String;
  TmpS:String;
begin
  StrOut:='RMA';
  Tmps:='0000001';
  StrOut:=StrOut+Tmps;
  Tmps:=IDFile;
  StrOut:=StrOut+Tmps;
  Tmps:=DateToYYYYMMDD(DataFile);
  StrOut:=StrOut+Tmps+'R01';
  StrOut:=RiempiFinoA(StrOut,' ',300);
  Save:=StrOut;
end;

{ TClsVerInadFoot }

constructor TClsVerInadFoot.Create;
begin

end;

destructor TClsVerInadFoot.Destroy;
begin

end;

procedure TClsVerInadFoot.Load(Tmps: String);
begin
  TipoRecord         :=Copy(Tmps,1,3); //RMZ
  ProgressivoRecord  :=StrToInt(Copy(Tmps,4,7));
  IDFile             :=Copy(Tmps,11,20);
  DataFile           :=YYYYMMDDToDate(Copy(Tmps,31,8));
  NumeroRecord       :=StrToInt(Copy(Tmps,39,7))
  //Filler           :String[255];
end;

function TClsVerInadFoot.Save: STring;
var
  StrTipoRecord:String;
  StrProgressivoRecord:String;
  StrIDFile:String;
  StrDataFile:String;
  StrNumeroRecord:String;
  StrOut:String;
  TmpS:String;
begin
  StrTipoRecord               :='RMZ';
  StrProgressivoRecord        :=IntToZeroPadded(ProgressivoRecord,7);
  StrIDFile                   :=IDFile;
  StrDataFile                 :=DateToYYYYMMDD(DataFile);
  StrNumeroRecord             :=IntToZeroPadded(NumeroRecord,7);
  StrOut:=StrTipoRecord+StrProgressivoRecord+StrIDFile+StrDataFile+StrNumeroRecord;
  StrOut:=RiempiFinoA(StrOut,' ',300);
  Save:=StrOut;
end;


{ TCVerInad }

constructor TCVerInad.Create;
begin
  SL:=TStringList.Create;
  Head:=TClsVerInadHead.Create;
  Beneficiari :=TClsVerInadListBeneficiario.Create;
  Foot:=TClsVerInadFoot.Create;
end;

destructor TCVerInad.Destroy;
begin
  SL.Free;
  Head.Free;
  Beneficiari.Free;
  Foot.Free;
end;

procedure TCVerInad.Load(aFilename: String);
var
  t:integer;
  NumLines:Integer;
begin
  Filename:=aFilename;
  SL.Clear;
  SL.LoadFromFile(aFilename);

  Beneficiari.Lista.Clear;

  NumLines:=SL.Count;
  Head.Load(Sl[0]);
  For t:=1 to NumLines-2 do
  begin
    Beneficiari.Insert(SL[t]);
  end;

  nCount:=SL.Count-1;

  Foot.Load(Sl[nCount]);
end;

procedure TCVerInad.Save(aFilename: String);
var
  SlOut:TStringList;
  ProgRec:Integer;
  i,n:integer;
  Beneficiario:TClsVerInadBeneficiario;
begin
  Head.IDFile:=NomeFileIRM;
  Foot.IDFile:=NomeFileIRM;

  ProgRec:=1;
  Head.ProgressivoRecord:=ProgRec;

  slOut:=TstringList.Create;
  SlOut.clear;

  SlOut.Add(Head.Save);
//  n:=Beneficiari.Count;

{  for i:=0 to n-1 do
  begin
    Beneficiario:=Beneficiari.Item(i);
    Inc(ProgRec);
    Beneficiario.B_ProgressivoRecord:=ProgRec;
    SlOut.Add(Beneficiario.Save);
  end;
}

  for Beneficiario in Beneficiari.Lista do
    begin
      Inc(ProgRec);
      Beneficiario.B_ProgressivoRecord := ProgRec;
      // Il progressivo richiesta solitamente riparte da 1 o segue ProgRec
      //Beneficiario.C_ProgressivoRichiesta := ProgRec - 1;
      SlOut.Add(Beneficiario.Save);
    end;

  inc(ProgRec);
  Foot.ProgressivoRecord:=ProgRec;
  Foot.NumeroRecord:=Beneficiari.Lista.Count;
  SlOut.Add(Foot.Save);
  SlOut.SaveToFile(aFilename);
  SlOut.free;
end;

function TCVerInad.GeneraNomeFileIRM(Anno: string; Progressivo: string): string;
var
  iProgressivo: Int64;
begin
  // Pulizia input
  Anno := Trim(Anno);
  Progressivo := Trim(Progressivo);

  // Se il progressivo è una stringa, lo convertiamo per assicurarci che sia numerico
  // e lo riformattiamo a 10 cifre con zeri a sinistra.
  if TryStrToInt64(Progressivo, iProgressivo) then
    NomeFileIRM := 'IRMEQS' + Anno + Format('%.10d', [iProgressivo])
  else
    // Fallback nel caso il progressivo non sia un numero valido
    NomeFileIRM := 'IRMEQS' + Anno + RiempiFinoA(Progressivo, '0', 10);
  Head.IDFile:=NomeFileIRM;
  Foot.IDFile:=NomeFileIRM;

  Result:=NomeFileIRM;
end;


end.

