{
      ORM Brasil � um ORM simples e descomplicado para quem utiliza Delphi

                   Copyright (c) 2016, Isaque Pinheiro
                          All rights reserved.

                    GNU Lesser General Public License
                      Vers�o 3, 29 de junho de 2007

       Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
       A todos � permitido copiar e distribuir c�pias deste documento de
       licen�a, mas mud�-lo n�o � permitido.

       Esta vers�o da GNU Lesser General Public License incorpora
       os termos e condi��es da vers�o 3 da GNU General Public License
       Licen�a, complementado pelas permiss�es adicionais listadas no
       arquivo LICENSE na pasta principal.
}

{ @abstract(ORMBr Framework.)
  @created(20 Jul 2016)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @author(Skype : ispinheiro)

  ORM Brasil � um ORM simples e descomplicado para quem utiliza Delphi.
}

unit ormbr.session.objectset;

interface

uses
  DB,
  Rtti,
  TypInfo,
  Classes,
  Variants,
  SysUtils,
  Generics.Collections,
  /// ORMBr
  ormbr.bind,
  ormbr.objects.manager,
  ormbr.session.abstract,
  dbebr.factory.interfaces;

type
  // M - Sess�o Abstract
  TSessionObjectSet<M: class, constructor> = class(TSessionAbstract<M>)
  protected
    FConnection: IDBConnection;
  public
    constructor Create(const AConnection: IDBConnection;
      const APageSize: Integer = -1); overload;
    destructor Destroy; override;
    procedure LoadLazy(const AOwner, AObject: TObject); override;
    procedure NextPacketList(const AObjectList: TObjectList<M>); overload; override;
    function NextPacketList: TObjectList<M>; overload; override;
    function NextPacketList(const APageSize, APageNext: Integer): TObjectList<M>; overload; override;
    function NextPacketList(const AWhere, AOrderBy: String;
      const APageSize, APageNext: Integer): TObjectList<M>; overload; override;
  end;

implementation

{ TSessionObjectSet<M> }

constructor TSessionObjectSet<M>.Create(const AConnection: IDBConnection; const APageSize: Integer);
begin
  inherited Create(APageSize);
  FConnection := AConnection;
  FManager := TObjectManager<M>.Create(Self, AConnection, APageSize);
end;

procedure TSessionObjectSet<M>.LoadLazy(const AOwner, AObject: TObject);
begin
  inherited;
  FManager.LoadLazy(AOwner, AObject);
end;

function TSessionObjectSet<M>.NextPacketList(const AWhere, AOrderBy: String;
  const APageSize, APageNext: Integer): TObjectList<M>;
begin
  inherited;
  Result := nil;
  if FFetchingRecords then
    Exit;
  Result := FManager.NextPacketList(AWhere, AOrderBy, APageSize, APageNext);
  if Result = nil then
    Exit;
  if Result.Count > 0 then
    Exit;
  FFetchingRecords := True;
end;

function TSessionObjectSet<M>.NextPacketList(const APageSize, APageNext: Integer): TObjectList<M>;
begin
  inherited;
  Result := nil;
  if FFetchingRecords then
    Exit;
  Result := FManager.NextPacketList(APageSize, APageNext);
  if Result = nil then
    Exit;
  if Result.Count > 0 then
    Exit;
  FFetchingRecords := True;
end;

destructor TSessionObjectSet<M>.Destroy;
begin
  FManager.Free;
  inherited;
end;

procedure TSessionObjectSet<M>.NextPacketList(const AObjectList: TObjectList<M>);
begin
  inherited;
  if FFetchingRecords then
    Exit;
  FPageNext := FPageNext + FPageSize;
  if FFindWhereUsed then
    FManager.NextPacketList(AObjectList, FWhere, FOrderBy, FPageSize, FPageNext)
  else
    FManager.NextPacketList(AObjectList, FPageSize, FPageNext);

  /// <summary>
  ///    if AObjectList = nil then
  ///      Exit;
  ///    if AObjectList.RecordCount > 0 then
  ///      Exit;
  ///    FFetchingRecords := True;
  ///  Esse c�digo para definir a tag FFetchingRecords, est� sendo feito no
  ///  m�todo NextPacketList() dentro do FManager.
  /// </summary>
end;

function TSessionObjectSet<M>.NextPacketList: TObjectList<M>;
begin
  inherited;
  Result := nil;
  if FFetchingRecords then
    Exit;
  FPageNext := FPageNext + FPageSize;
  if FFindWhereUsed then
    Result := FManager.NextPacketList(FWhere, FOrderBy, FPageSize, FPageNext)
  else
    Result := FManager.NextPacketList(FPageSize, FPageNext);

  if Result = nil then
    Exit;
  if Result.Count > 0 then
    Exit;
  FFetchingRecords := True;
end;

end.
