class EPController extends OLPlayerController;

struct Position
{
    Var vector Pos;
    Var Rotator Rot;
};

Var Float fDebugSpeed, FBBrightness, FBRadius;
Var bool bFreeCamOn, bFb, bCPActive;
Var array<Position> SavedPositions;
Var EPHud EPHud;
Var EPInput EPInput;
var Vector2D ViewportCurrentSize;
var Transient OLCheatManager CheatManager;
var Class<OLCheatManager> CheatClass;

exec function Reload(){
    if(class'OLUtils'.static.IsPlayingDLC()){
        CP("Hospital_Free");
    }
    else{
        CP("Admin_Gates");
    }
}

Exec Function CTV(String Command)
{
    ConsoleCommand(Command @PasteFromClipboard());
}


Function BigMsg(string Text, float Duration =5)
{
    EPHud(Hud).BigMsgStr =Text;
    EPHud(Hud).DisplayMsg=true;
    SetTimer(Duration, false, 'StopMsg');
}

Function StopMsg()
{
    EPHud(Hud).DisplayMsg=false;
    EPHud(Hud).BigMsgStr="";    
}

Exec Function SavePos(int Index =0)
{
    Local Position PosToAdd;

    PosToAdd.Pos =EPHero(Pawn).Location;
    PosToAdd.Rot =EPHero(Pawn).Rotation;
    SavedPositions[Index] =PosToAdd;
}

Exec Function LoadPos(int Index =0)
{
    EPHero(Pawn).SetLocation(SavedPositions[Index].Pos);
    EPHero(Pawn).SetRotation(SavedPositions[Index].Rot);
}

Function UpdateJumps(float Damage =0, int ResetTime =0)
{
    if(Damage==0)
    {
        EPHud(Hud).TopLeftStr ="Infinite";
    }
    else if(Damage >=100)
    {
        EPHud(Hud).TopLeftStr ="InstaDeath";
    }
    else
    {
        EPHud(Hud).TopLeftStr=int(100/Damage)$"|"$ResetTime;
    }
}

Exec Function FullBright(Float Bright=0.5, Float Radius=1024)
{
    bFB =!bFb;
    FBBrightness =Bright;
    FBRadius =Radius;
    EPHero(Pawn).FullBright(Bright, Radius);
}

exec function SetBrightness(float Amount){
    if(bFB){
        FBBrightness +=amount;
        EPHero(Pawn).FullBright(FBBrightness, FBRadius);
    }
}

Exec Function SetGameSpeed(Float Speed=1) {
    WorldInfo.Game.SetGameSpeed(Speed);
}

Function SetGrainBrightness(float B=0.8) 
{
    FXManager.CurrentUberPostEffect.GrainBrightness = B;
}

Exec Function ToggleFreeCam()
{
    bFreeCamOn =!bFreeCamOn;
    if(bFreeCamOn)
    {
        ConsoleCommand("Camera FreeCam");
    }
    else
    {
        ConsoleCommand("Camera Default");
    }
}

Exec Function CP(String Checkpoint, Bool Save=true) {
    if(Class'CPList'.static.IsCP(name(Checkpoint))) {
        ConsoleCommand("Streammap All_Checkpoints");
        Kill();
        EPHero(Pawn).RespawnHero();
        StartNewGameAtCheckpoint(Checkpoint, Save);
    }
    else{
        SendMsg("Du hasts vermurgst...");
    }
}

exec function Kill(optional OLEnemyPawn P){
    class'EnemyUtils'.static.init().Kill(P);
}

Exec Function ToggleConsole(Bool Show) {
    Switch(Show) {
        case true:
            EPHud(HUD).ToggleHUD = true;
            DisableInput(true);
            DebugFreeCamSpeed = 0;
            break;
        case false:
            EPHud(HUD).ToggleHUD = false;
            DisableInput(false);
            PlayerInput.ResetInput();
            DebugFreeCamSpeed = fDebugSpeed;
            break;
    }
}

Function DisableInput(Bool Input) {
    local EPInput HeroInput;
    local EPHero Hero;

    HeroInput = EPInput(PlayerInput);
    Hero = EPHero(Pawn);
    if(Hero == None) {
        return;
    }
    if(Input) {
        HeroInput.MoveCommand="asdtyunbv";
        HeroInput.StrafeCommand="asdtyunbv";
        HeroInput.LookXCommand="asdtyunbv";
        HeroInput.LookYCommand="asdtyunbv";
        Hero.NormalWalkSpeed=0;
        Hero.NormalRunSpeed=0;
        Hero.CrouchedSpeed=0;
        Hero.ElectrifiedSpeed=0;
        Hero.WaterWalkSpeed=0;
        Hero.WaterRunSpeed=0;
        Hero.LimpingWalkSpeed=0;
        Hero.HobblingWalkSpeed=0;
        Hero.HobblingRunSpeed=0;
        IgnoreLookInput(true);
        IgnoreMoveInput(true);
    }
    else 
    {
        HeroInput.MoveCommand=HeroInput.Default.MoveCommand;
        HeroInput.StrafeCommand=HeroInput.Default.StrafeCommand;
        HeroInput.LookXCommand=HeroInput.Default.LookXCommand;
        HeroInput.LookYCommand=HeroInput.Default.LookYCommand;
        Hero.NormalWalkSpeed=Hero.Default.NormalWalkSpeed;
        Hero.NormalRunSpeed=Hero.Default.NormalRunSpeed;
        Hero.CrouchedSpeed=Hero.Default.CrouchedSpeed;
        Hero.ElectrifiedSpeed=Hero.Default.ElectrifiedSpeed;
        Hero.WaterWalkSpeed=Hero.Default.WaterWalkSpeed;
        Hero.WaterRunSpeed=Hero.Default.WaterRunSpeed;
        Hero.LimpingWalkSpeed=Hero.Default.LimpingWalkSpeed;
        Hero.HobblingWalkSpeed=Hero.Default.HobblingWalkSpeed;
        Hero.HobblingRunSpeed=Hero.Default.HobblingRunSpeed;
        IgnoreLookInput(false);
        IgnoreMoveInput(false);
    }
    HeroInput.bWasForward=false;
    HeroInput.bWasBack=false;
    HeroInput.bWasLeft=false;
    HeroInput.bWasRight=false;
    HeroInput.bEdgeForward=false;
    HeroInput.bEdgeBack=false;
    HeroInput.bEdgeLeft=false;
    HeroInput.bEdgeRight=false;
}

Function SendMsg(String Msg, Float LifeTime=3.0) 
{
    EPHud(HUD).AddConsoleMessage(Msg, Class'LocalMessage', PlayerReplicationInfo, LifeTime);
    PlaySound(SoundCue'EPlusAssets.Sound.Message_Cue');
}

Simulated Event PostBeginPlay() 
{
    Super(PlayerController).PostBeginPlay();
    if(TutorialManager != none) {
        TutorialManager.Clear();
    }
    bProfileSettingsUpdated = true;
    CheatManager = new (Self) CheatClass;
    CheatManager.InitCheatManager();
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    super(PlayerController).Possess(inPawn, bVehicleTransition);
    HeroPawn = EPHero(inPawn);
    bDuck = 0;
}

Event Tick(Float DeltaTime) 
{
    LocalPlayer(Player).ViewportClient.GetViewportSize(ViewportCurrentSize);
    EPHero(Pawn).Camera.ViewCS.Yaw = 180;
    EPHero(Pawn).Camera.ViewCS.Pitch = 180;
    Super.Tick(DeltaTime);
}

DefaultProperties
{
    fDebugSpeed = 0.0040
    InputClass = Class'EPInput'
    CheatClass = Class'OLCheatManager'
}