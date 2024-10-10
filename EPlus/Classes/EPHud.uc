Class EPHud extends OLHud;

struct RGBA 
{
    var Byte Red;
    var Byte Green;
    var Byte Blue;
    var Byte Alpha;

    structdefaultproperties
    {
        Red=255
        Green=255
        Blue=255
        Alpha=255
    }
};

var Bool ToggleHUD, DisplayMsg;
var RGBA PushColor;
var EPInput EPInput;
var String Command, StrPushMessage, TopLeftStr, TopMiddleStr, BigMsgStr;

/************************MENU FUNCTION************************/
Function PostRender()
{
    super.PostRender();
    Canvas.Font =Font'EPlusAssets.Font.Font_0';
    DrawString(TopLeftStr, Vect2D(5, 5),MakeRGBA(154,0,255,255),Vect2D(3.5, 3.5));
    if(TopMiddleStr !="")
    {
        DrawString(TopMiddleStr, Vect2D(900, 5),MakeRGBA(154,0,255,255),Vect2D(5, 5));
    }
    if(DisplayMsg)
    {
        DrawString(BigMsgStr, Vect2D(600, 400),MakeRGBA(255,255,255,255),Vect2D(10, 10));
    }
    if(ToggleHUD){
        ShowConsoleMenu();
        return;
    }
}

Function ShowConsoleMenu() 
{
    local Vector2D StartClip, EndClip, Temp_Begin, Temp_End, TempTextSize, TempOffset;

    EndClip = EndClip;

    DrawBox(Vect2D(265, 145), Vect2D(750, 500), MakeRGBA(1,1,1,200), StartClip, EndClip);
    DrawBox(Vect2D(265, 130), Vect2D(750, 15), MakeRGBA(30, 30, 33, 230));

    DrawConsoleString(">" @ Command, Vect2D(400, 194), MakeRGBA(210, 210, 220, 255), Vect2D(1.8, 1.8));

    Canvas.SetPos(6, Canvas.ClipY - 18.7);
    Canvas.SetDrawColor(0, 0, 0, 255);
    Canvas.DrawText("Rafy's shamelessly riped console Menue...", false, 0.8, 0.8);

    Canvas.SetPos(5, Canvas.ClipY - float(20));
    Canvas.SetDrawColor(255, 255, 255, 255);
    Canvas.DrawText("Rafy's shamelessly riped console Menue...", false, 0.8, 0.8);
}

/************************OTHER FUNCTIONS************************/

Exec Function PushMessage(String Msg) {
    StrPushMessage = Msg;
    PushColor = MakeRGBA(255, 255, 255, 255);
    WorldInfo.Game.ClearTimer('PushMessageHide', Self);
    WorldInfo.Game.SetTimer(0.005, true, 'PushMessageHide', Self);
}

Function PushMessageHide() {
    if(PushColor.Alpha == 0) {
        StrPushMessage = "";
        PushColor = MakeRGBA(0,0,0,0);
        WorldInfo.Game.ClearTimer('PushMessageHide', Self);
        return;
    }
    PushColor.Alpha = PushColor.Alpha - 1;
}


Function AddConsoleMessage(string M, class<LocalMessage> InMessageClass, PlayerReplicationInfo PRI, optional float LifeTime) {
	local Int Idx, MsgIdx;

	MsgIdx = -1;
	if( bMessageBeep && InMessageClass.default.bBeep )
	{
		PlayerOwner.PlayBeepSound();
	}
	if (ConsoleMessages.Length < ConsoleMessageCount)
	{
		MsgIdx = ConsoleMessages.Length;
	}
	else
	{
		for (Idx = 0; Idx < ConsoleMessages.Length && MsgIdx == -1; Idx++)
		{
			if (ConsoleMessages[Idx].Text == "")
			{
				MsgIdx = Idx;
			}
		}
	}
    if( MsgIdx == ConsoleMessageCount || MsgIdx == -1)
    {
		// push up the array
		for(Idx = 0; Idx < ConsoleMessageCount-1; Idx++ )
		{
			ConsoleMessages[Idx] = ConsoleMessages[Idx+1];
		}
		MsgIdx = ConsoleMessageCount - 1;
    }
	// fill in the message entry
	if (MsgIdx >= ConsoleMessages.Length)
	{
		ConsoleMessages.Length = MsgIdx + 1;
	}

    ConsoleMessages[MsgIdx].Text = M;
	if (LifeTime != 0.f)
	{
		ConsoleMessages[MsgIdx].MessageLife = WorldInfo.TimeSeconds + LifeTime;
	}
	else
	{
		ConsoleMessages[MsgIdx].MessageLife = WorldInfo.TimeSeconds + InMessageClass.default.LifeTime;
	}

    ConsoleMessages[MsgIdx].TextColor = InMessageClass.static.GetConsoleColor(PRI);
    ConsoleMessages[MsgIdx].PRI = PRI;
}

Function DrawString(String String, Vector2D Loc, optional RGBA Color=MakeRGBA(200, 200, 200, 200), optional Vector2D Scale=Vect2D(1.5, 1.5), optional Bool ScaleLoc=true, optional Bool center) {
    local Vector2D MisScale, StringScale;

    MisScale = Vect2D((0.7 * Scale.X) / 1920 * Canvas.SizeX, (0.7 * Scale.Y) / 1080 * Canvas.SizeY);
    Canvas.TextSize(String, StringScale.X, StringScale.Y, MisScale.X, MisScale.Y);

    if(Center) {
        Loc=Vect2D(Loc.X - (StringScale.X / 2), Loc.Y - (StringScale.Y / 2));
    }
    if(ScaleLoc) {
        Loc=Vect2D(Loc.X / 1920 * Canvas.SizeX, Loc.Y / 1080 * Canvas.SizeY);
    }

    Canvas.SetDrawColor(0, 0, 0, 255);
    Canvas.SetPos(Loc.X+1, Loc.Y+1.3);
    Canvas.DrawText(String, false, MisScale.X, MisScale.Y);

    Canvas.SetPos(Loc.X, Loc.Y);
    Canvas.SetDrawColor(Color.Red, Color.Blue, Color.Green, Color.Alpha);
    Canvas.DrawText(String, false, MisScale.X, MisScale.Y);
}

Function DrawConsoleString(String String, Vector2D Loc, optional RGBA Color=MakeRGBA(200, 200, 200, 200), optional Vector2D Scale=Vect2D(2, 2), optional Bool ScaleLoc=true, optional Bool center) {
    local Vector2D MisScale, StringScale, StringLoc, ViewportSize;
    local Float XL, YL, Y, info_xl, info_yl;
    local EPInput PlayerInput;
    local EPController Controller;
    local String OutStr, Cursor;
    local Int MatchIdx, Idx, StartIdx;

    Controller = EPController(PlayerOwner);
    if(Controller != None) {
        Controller.ViewportCurrentSize = ViewportSize;
        StringScale.X = ViewportSize.X;
        StringScale.Y = ViewportSize.Y;
    }
    else {
        StringScale.X = 1920;
        StringScale.Y = 1080;
    }
    PlayerInput = EPInput(PlayerOwner.PlayerInput);
    Cursor = "_";
    MisScale = Vect2D((1.3) / Canvas.SizeX * Canvas.SizeX, (1.3) / Canvas.SizeY * Canvas.SizeY);
    Loc = Vect2D(Loc.X / 1920 * Canvas.SizeX, Loc.Y / 1080 * Canvas.SizeY);

    Canvas.SetPos(Loc.X+1, Loc.Y+1.3);
    Canvas.SetDrawColor(0, 0, 0, Color.Alpha);
    Canvas.DrawText(String, false, MisScale.X, MisScale.Y);

    Canvas.SetPos(Loc.X, Loc.Y);
    Canvas.SetDrawColor(Color.Red, Color.Blue, Color.Green, Color.Alpha);
    Canvas.DrawText(String, false, MisScale.X, MisScale.Y);
 
    OutStr = ">" @ Left(Command, PlayerInput.CommandPos);

    Canvas.StrLen(OutStr, XL, YL);
    Canvas.SetPos(Loc.X+1 + (XL*1.3), Loc.Y+1.3);
    Canvas.SetDrawColor(0, 0, 0, Color.Alpha);
    Canvas.DrawText(Cursor, false, MisScale.X, MisScale.Y); //1.3, 1.3

    Canvas.StrLen(OutStr, XL, YL);
    Canvas.SetPos(Loc.X + (XL*1.3), Loc.Y);
    Canvas.SetDrawColor(Color.Red, Color.Blue, Color.Green, Color.Alpha);
    Canvas.DrawText(Cursor, false, MisScale.X, MisScale.Y);
}

Function Bool ContainsName(Array<Name> Array, Name find) {
    Switch(Array.Find(Find)) {
        case -1: return false;
        Default: return true;
    }
}

Function Bool ContainsString(Array<String> Array, String find) {
    Switch(Array.Find(Find)) {
        case -1:
            return false;
            break;
        Default:
            return true;
            break;
    }
}

Function bool InRange(float Target, Float RangeMin, Float RangeMax) {
    return Target > RangeMin && Target < RangeMax;
}

Function DrawTextInWorld(String Text, Vector location, Float Max_View_Distance, Float scale, optional Vector offset) {
    local Vector DrawLocation, CameraLocation; //Location to Draw Text & Location of Player Camera
    local Rotator CameraDir; //Direction the camera is facing
    local Float Distance; //Distance between Camera and text

    PlayerOwner.GetPlayerViewPoint(CameraLocation, CameraDir);
    Distance =  ScaleByCam(VSize(CameraLocation - Location)); //Get the distance between the camera and the location of the text being placed, then scale it by the camera's FOV. 
    DrawLocation = Canvas.Project(Location); //Project the 3D location into 2D space. 
    if(Vector(CameraDir) dot (Location - CameraLocation) > 0.0 && Distance < Max_View_Distance) {
        Scale = Scale / Distance; //Scale By distance. 
        Canvas.SetPos(DrawLocation.X + (Offset.X * Scale), DrawLocation.Y + (Offset.Y * Scale), DrawLocation.Z + (Offset.Z * Scale)); //Set the Position of text using the Draw Location and an optional Offset. 
        Canvas.SetDrawColor(255,40,40,255);
        Canvas.DrawText(Text, false, Scale, Scale);
    }
}

Function DrawBox(Vector2D Begin_Point, Vector2D End_Point, RGBA Color=MakeRGBA(255,255,255,255), optional out Vector2D Begin_Point_Calculated, optional out Vector2D End_Point_Calculated) {
    Begin_Point_Calculated = Scale2DVector(Begin_Point);
    End_Point_Calculated = Scale2DVector(End_Point);
    Canvas.SetPos(Begin_Point_Calculated.X, Begin_Point_Calculated.Y);
    Canvas.SetDrawColor(Color.Red,Color.Green,Color.Blue,Color.Alpha);
    Canvas.DrawRect(End_Point_Calculated.X, End_Point_Calculated.Y);
}

Function Float ScaleByCam(Float Float) {
    return Float * (PlayerOwner.GetFOVAngle() / 100);
}

Function Vector2D Scale2DVector(Vector2D Vector) {
    Vector.X=Vector.X / 1280.0f * Canvas.SizeX;
    Vector.Y=Vector.Y / 720.0f * Canvas.SizeY;
    return Vector;
}

Function Bool Vector2DInRange(Vector2D Target, Vector2D Vector1, Vector2D Vector2) {
    return InRange(Target.X, Vector1.X, Vector2.X) && InRange(Target.Y, Vector1.Y, Vector2.Y);
}

Function String VectorToString(Vector Target) {
    return Target.X $ "," @ Target.Y $ "," @ Target.Z;
}

Function Commit() {
    local EPController Controller;
    local EPInput PlayerInput;
    
    Controller = EPController(PlayerOwner);
    PlayerInput = EPInput(PlayerOwner.PlayerInput);
    PlayerOwner.ConsoleCommand(Command);
    Command="";
    PlayerInput.SetCursorPos(0);
}

Function RGBA MakeRGBA(Byte R, Byte G, Byte B, Byte A=255) {
    local RGBA Color;
    
    Color.Red=R;
    Color.Green=G;
    Color.Blue=B;
    Color.Alpha=A;
    return Color;
}

Function Color MakeLineColor(Byte R, Byte G, Byte B, Byte A=255) {
    local Color Color;

    Color.R=R;
    Color.G=G;
    Color.B=B;
    Color.A=A;

    return Color;
}

DefaultProperties
{
    TopMiddleStr =""
    TopLeftStr =""
    BigMsgStr =""
}