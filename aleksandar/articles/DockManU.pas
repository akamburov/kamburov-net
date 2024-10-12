//-- Dock Manager unit ---------------------------------------------------------
//
//  Copyright © 2001-2003 Alexander Kamburov
//  wise_guybg@yahoo.com
//
//-------- Usage ---------------------------------------------------------------
//
//    unit Form1;
//
//    interface
//
//    uses
//      Windows, SysUtils;
//
//    type
//      TForm1 = class(TForm)
//    protected
//      procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
//      procedure WMMoving(var Msg: TWMMoving); message WM_MOVING;
//    end;
//
//    implementation
//
//    uses
//      DockManU;
//
//    procedure TForm1.WMSysCommand(var Msg: TWMSysCommand);
//    begin
//      DockMan.CheckCommand(Msg.CmdType);
//      inherited;
//    end;
//
//    procedure TForm1.WMMoving(var Msg: TWMMoving);
//    begin
//      if bNeedDocking then DockMan.PerformDock(iDistance, Msg.DragRect^);
//      inherited;
//    end;
//
//------------------------------------------------------------------------------
unit DockManU;

interface

uses
  Windows, SysUtils;

type
  TDockMan = class
  private
    FMoved: TPoint;
  public
    procedure CheckCommand(const ACmtType: Integer);
    procedure PerformDock(const ADistance: Integer; var ADragRect: TRect);
  end;

//Singleton function declaration
function DockMan: TDockMan;

implementation

uses Forms;

//------------------------------------------------------------------------------
procedure TDockMan.CheckCommand(const ACmtType: Integer);
const
  SC_DRAGMOVE = $F012;
begin
  if (ACmtType = SC_MOVE) or (ACmtType = SC_DRAGMOVE) then
  begin //a new move was started
    FMoved.X := 0;
    FMoved.Y := 0;
  end;
end;//CheckCommand
//------------------------------------------------------------------------------
procedure TDockMan.PerformDock(const ADistance: Integer; var ADragRect: TRect);
var
  Width, Height: Integer;

  procedure DockToBorder(const ABorder: Integer; var APosition, AChangedPosition: Integer);
  begin
    if Abs(ABorder - APosition) < ADistance then
    begin //the position has to change
      if Abs(AChangedPosition) > ADistance then
      begin //we need undocking
        APosition := APosition + AChangedPosition; //realize position
        AChangedPosition := 0; //nil the moved variable
      end
        else if APosition <> ABorder then
        begin //we need to dock the window
          AChangedPosition := AChangedPosition + APosition - ABorder; //add new change to the old
          APosition := ABorder; //set new position
        end;
    end;
  end; //DockToBorder

begin
  //get drag rectangle dimensions
  Width  := ADragRect.Right  - ADragRect.Left;
  Height := ADragRect.Bottom - ADragRect.Top;

  with Screen.WorkAreaRect do
  begin //do dock for all four borders
    DockToBorder(Left, ADragRect.Left, FMoved.X);
    DockToBorder(Top, ADragRect.Top, FMoved.Y);
    DockToBorder(Right - Width, ADragRect.Left, FMoved.X);
    DockToBorder(Bottom - Height, ADragRect.Top, FMoved.Y);
  end;

  //realize drag rectangle dimensions
  ADragRect.Right  := ADragRect.Left + Width;
  ADragRect.Bottom := ADragRect.Top  + Height;
end;//PerformDock
//------------------------------------------------------------------------------

//Singleton implementation
var
  GDockMan: TDockMan;

function DockMan: TDockMan;
begin
  if GDockMan = nil then
    GDockMan := TDockMan.Create;
  Result := GDockMan;
end;

initialization

finalization
  DockMan.Free;

end.
