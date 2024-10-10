Class EPInput extends OLPlayerInput within EPController;

var Array<Name> Keys;
var Int CommandPos;
var() globalconfig bool bUseHardwareCursor;
var bool bForcedSoftwareCursor; // If Gamepad is used, we can't use the hardware cursor.

var() globalconfig float ControlStickSensitivityHor;
var() globalconfig float ControlStickSensitivityVert;

Function SetCursorPos(Int Pos) {
    CommandPos = Pos;
}

Function InputCommand(String Text) {
    EPHud(HUD).Command = Text;
}

Function Bool Key(Int ControllerId, Name Key, EInputEvent Event, Float AmountDepressed=1.f, Bool bGamepad=false) {
    local Name PKName;
    local Int PKIndex, NewPos, SpacePos, PeriodPos;

    if(EPHud(HUD).ToggleHUD && Event == IE_Pressed || EPHud(HUD).ToggleHUD && Event == IE_Repeat) {
            Switch(Key) {
                case 'Enter':
                    EPHud(HUD).Commit();
                    break;
                case 'Left':
                    SetCursorPos(Max(0, CommandPos - 1));
                    break;
                case 'Right':
                    SetCursorPos(Min(Len(EPHud(HUD).Command), CommandPos + 1));
                    break;
                case 'Delete':
                    InputCommand("");
                    SetCursorPos(0);
                    break;
                case 'Backspace':
                    InputCommand(Left(EPHud(HUD).Command, CommandPos - 1) $ Right(EPHud(HUD).Command, Len(EPHud(HUD).Command) - CommandPos));
                    if(CommandPos > 0) {
                        SetCursorPos(CommandPos - 1);
                    }
                    break;
                case 'Tilde':
                    ToggleConsole(false);
                    break;
                }
            return true;
        }
    return false;
}

Function Bool Char(Int ControllerId, String Unicode) {
    local Int Character;

    Character = Asc(Left(Unicode, 1));
    if(EPHud(HUD).ToggleHUD) {
        if(Character >= 0x20 && Character < 0x100 && Unicode != "`" && Character != 0x7f || Character >= 0x410 && Character < 0x450 && Unicode != "`" && Character != 0x7f) {
            InputCommand((Left(EPHud(HUD).Command, CommandPos) $ Chr(Character)) $ Right(EPHud(HUD).Command, Len(EPHud(HUD).Command) - CommandPos));
            SetCursorPos(CommandPos + 1);
        }
        return true;
    }
    return false;
}

DefaultProperties
{
    YawAccelThreshold = 0.90
    OnReceivedNativeInputKey = Key
    OnReceivedNativeInputChar = Char
}