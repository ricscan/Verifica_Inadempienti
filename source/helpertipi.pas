unit HelperTipi;

{$mode ObjFPC}{$H+}

interface
{$modeswitch typehelpers}

uses Classes,SysUtils;

type
  // Definiamo un alias per chiarezza, ma l'helper funzionerà sull'intero
  TImporto = Integer;

  { Definizione dell'Helper }
  TImportoHelper = type helper for TImporto
    function AsString: string;
  end;


implementation

{ Implementazione del metodo }
function TImportoHelper.AsString: string;
begin
  Result := IntToStr(Self);
end;

end.



