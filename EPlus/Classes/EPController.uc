class EPController extends OLPlayerController;

struct Position
{
    Var vector Pos;
    Var Rotator Rot;
};

Var Float fDebugSpeed;
Var bool bFreeCamOn, bFb, bCPActive;
Var array<Position> SavedPositions;
Var EPHud EPHud;
Var EPInput EPInput;
Var EPPointLight EPL;
var Vector2D ViewportCurrentSize;
var Transient OLCheatManager CheatManager;
var Class<OLCheatManager> CheatClass;

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

Exec Function FullBright(Float Bright=0.5, Float Radius=1024, Byte R=255, Byte G=255, Byte B=255, Byte A=125, Bool Shadows=true)
{
    bFB =!bFb;
    if(bFb)
    {
        EPL =Spawn(Class'EPPointLight');
        EPL.SetBrightness(Bright);
        EPL.SetColor(R,G,B,A);
        EPL.SetRadius(Radius);
        EPL.SetCastDynamicShadows(Shadows);
        WorldInfo.Game.SetTimer(0.001, true, 'FBMove', self);
    }
    else
    {
        WorldInfo.Game.ClearTimer('FBMove', self);
        EPL.Destroy();
    }
}

Function FBMove()
{
    Local Vector C;
    Local Rotator R;
    GetPlayerViewPoint(C,R);
    EPL.SetLocation(C);
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
    local OLCheckpointList FullList, List, List2;
    local EPGame CGame;
    local Name CPName;

    CGame = EPGame(WorldInfo.Game);

    List = Spawn(Class'OLCheckpointList');
    List2 = Spawn(Class'OLCheckpointList');
    List.GameType = OGT_Outlast;
    List.CheckpointList[0] = 'StartGame';
    List.CheckpointList[1] = 'Admin_Gates';
    List.CheckpointList[2] = 'Admin_Garden';
    List.CheckpointList[3] = 'Admin_Explosion';
    List.CheckpointList[4] = 'Admin_Mezzanine';
    List.CheckpointList[5] = 'Admin_MainHall';
    List.CheckpointList[6] = 'Admin_WheelChair';
    List.CheckpointList[7] = 'Admin_SecurityRoom';
    List.CheckpointList[8] = 'Admin_Basement';
    List.CheckpointList[9] = 'Admin_Electricity';
    List.CheckpointList[10] = 'Admin_PostBasement';
    List.CheckpointList[11] = 'Prison_Start';
    List.CheckpointList[12] = 'Prison_IsolationCells01_Mid';
    List.CheckpointList[13] = 'Prison_ToPrisonFloor';
    List.CheckpointList[14] = 'Prison_PrisonFloor_3rdFloor';
    List.CheckpointList[15] = 'Prison_PrisonFloor_SecurityRoom1';
    List.CheckpointList[16] = 'Prison_PrisonFloor02_IsolationCells01';
    List.CheckpointList[17] = 'Prison_Showers_2ndFloor';
    List.CheckpointList[18] = 'Prison_PrisonFloor02_PostShowers';
    List.CheckpointList[19] = 'Prison_PrisonFloor02_SecurityRoom2';
    List.CheckpointList[20] = 'Prison_IsolationCells02_Soldier';
    List.CheckpointList[21] = 'Prison_IsolationCells02_PostSoldier';
    List.CheckpointList[22] = 'Prison_OldCells_PreStruggle';
    List.CheckpointList[23] = 'Prison_OldCells_PreStruggle2';
    List.CheckpointList[24] = 'Prison_Showers_Exit';
    List.CheckpointList[25] = 'Sewer_start';
    List.CheckpointList[26] = 'Sewer_FlushWater';
    List.CheckpointList[27] = 'Sewer_WaterFlushed';
    List.CheckpointList[28] = 'Sewer_Ladder';
    List.CheckpointList[29] = 'Sewer_ToCitern';
    List.CheckpointList[30] = 'Sewer_Citern1';
    List.CheckpointList[31] = 'Sewer_Citern2';
    List.CheckpointList[32] = 'Sewer_PostCitern';
    List.CheckpointList[33] = 'Sewer_ToMaleWard';
    List.CheckpointList[34] = 'Male_Start';
    List.CheckpointList[35] = 'Male_Chase';
    List.CheckpointList[36] = 'Male_ChasePause';
    List.CheckpointList[37] = 'Male_Torture';
    List.CheckpointList[38] = 'Male_TortureDone';
    List.CheckpointList[39] = 'Male_surgeon';
    List.CheckpointList[40] = 'Male_GetTheKey';
    List.CheckpointList[41] = 'Male_GetTheKey2';
    List.CheckpointList[42] = 'Male_Elevator';
    List.CheckpointList[43] = 'Male_ElevatorDone';
    List.CheckpointList[44] = 'Male_Priest';
    List.CheckpointList[45] = 'Male_Cafeteria';
    List.CheckpointList[46] = 'Male_SprinklerOff';
    List.CheckpointList[47] = 'Male_SprinklerOn';
    List.CheckpointList[48] = 'Courtyard_Start';
    List.CheckpointList[49] = 'Courtyard_Corridor';
    List.CheckpointList[50] = 'Courtyard_Chapel';
    List.CheckpointList[51] = 'Courtyard_Soldier1';
    List.CheckpointList[52] = 'Courtyard_Soldier2';
    List.CheckpointList[53] = 'Courtyard_FemaleWard';
    List.CheckpointList[54] = 'Female_Start';
    List.CheckpointList[55] = 'Female_Mainchute';
    List.CheckpointList[56] = 'Female_2ndFloor';
    List.CheckpointList[57] = 'Female_2ndfloorChute';
    List.CheckpointList[58] = 'Female_ChuteActivated';
    List.CheckpointList[59] = 'Female_Keypickedup';
    List.CheckpointList[60] = 'Female_3rdFloor';
    List.CheckpointList[61] = 'Female_3rdFloorHole';
    List.CheckpointList[62] = 'Female_3rdFloorPosthole';
    List.CheckpointList[63] = 'Female_Tobigjump';
    List.CheckpointList[64] = 'Female_LostCam';
    List.CheckpointList[65] = 'Female_FoundCam';
    List.CheckpointList[66] = 'Female_Chasedone';
    List.CheckpointList[67] = 'Female_Exit';
    List.CheckpointList[68] = 'Female_Jump';
    List.CheckpointList[69] = 'Revisit_Soldier1';
    List.CheckpointList[70] = 'Revisit_Mezzanine';
    List.CheckpointList[71] = 'Revisit_ToRH';
    List.CheckpointList[72] = 'Revisit_RH';
    List.CheckpointList[73] = 'Revisit_FoundKey';
    List.CheckpointList[74] = 'Revisit_To3rdfloor';
    List.CheckpointList[75] = 'Revisit_3rdFloor';
    List.CheckpointList[76] = 'Revisit_RoomCrack';
    List.CheckpointList[77] = 'Revisit_ToChapel';
    List.CheckpointList[78] = 'Revisit_PriestDead';
    List.CheckpointList[79] = 'Revisit_Soldier3';
    List.CheckpointList[80] = 'Revisit_ToLab';
    List.CheckpointList[81] = 'Lab_Start';
    List.CheckpointList[82] = 'Lab_PremierAirlock';
    List.CheckpointList[83] = 'Lab_SwarmIntro';
    List.CheckpointList[84] = 'Lab_SwarmIntro2';
    List.CheckpointList[85] = 'Lab_Soldierdead';
    List.CheckpointList[86] = 'Lab_SpeachDone';
    List.CheckpointList[87] = 'Lab_SwarmCafeteria';
    List.CheckpointList[88] = 'Lab_EBlock';
    List.CheckpointList[89] = 'Lab_ToBilly';
    List.CheckpointList[90] = 'Lab_BigRoom';
    List.CheckpointList[91] = 'Lab_BigRoomDone';
    List.CheckpointList[92] = 'Lab_BigTower';
    List.CheckpointList[93] = 'Lab_BigTowerStairs';
    List.CheckpointList[94] = 'Lab_BigTowerMid';
    List.CheckpointList[95] = 'Lab_BigTowerDone';
    List2.GameType = OGT_Whistleblower;
    List2.CheckpointList[0] = 'DLC_Start';
    List2.CheckpointList[1] = 'DLC_Lab_Start';
    List2.CheckpointList[2] = 'Lab_AfterExperiment';
    List2.CheckpointList[3] = 'Hospital_Start';
    List2.CheckpointList[4] = 'Hospital_Free';
    List2.CheckpointList[5] = 'Hospital_1stFloor_ChaseStart';
    List2.CheckpointList[6] = 'Hospital_1stFloor_ChaseEnd';
    List2.CheckpointList[7] = 'Hospital_1stFloor_dropairvent';
    List2.CheckpointList[8] = 'Hospital_1stFloor_SAS';
    List2.CheckpointList[9] = 'Hospital_1stFloor_Lobby';
    List2.CheckpointList[10] = 'Hospital_1stFloor_NeedHandCuff';
    List2.CheckpointList[11] = 'Hospital_1stFloor_GotKey';
    List2.CheckpointList[12] = 'Hospital_1stFloor_Chase';
    List2.CheckpointList[13] = 'Hospital_1stFloor_Crema';
    List2.CheckpointList[14] = 'Hospital_1stFloor_Bake';
    List2.CheckpointList[15] = 'Hospital_1stFloor_Crema2';
    List2.CheckpointList[16] = 'Hospital_2ndFloor_Crema';
    List2.CheckpointList[17] = 'Hospital_2ndFloor_Canibalrun';
    List2.CheckpointList[18] = 'Hospital_2ndFloor_Canibalgone';
    List2.CheckpointList[19] = 'Hospital_2ndFloor_ExitIsLocked';
    List2.CheckpointList[20] = 'Hospital_2ndFloor_RoomsCorridor';
    List2.CheckpointList[21] = 'Hospital_2ndFloor_ToLab';
    List2.CheckpointList[22] = 'Hospital_2ndFloor_Start_Lab_2nd';
    List2.CheckpointList[23] = 'Hospital_2ndFloor_GazOff';
    List2.CheckpointList[24] = 'Hospital_2ndFloor_Labdone';
    List2.CheckpointList[25] = 'Hospital_2ndFloor_Exit';
    List2.CheckpointList[26] = 'Courtyard1_Start';
    List2.CheckpointList[27] = 'Courtyard1_RecreationArea';
    List2.CheckpointList[28] = 'Courtyard1_DupontIntro';
    List2.CheckpointList[29] = 'Courtyard1_Basketball';
    List2.CheckpointList[30] = 'Courtyard1_SecurityTower';
    List2.CheckpointList[31] = 'PrisonRevisit_Start';
    List2.CheckpointList[32] = 'PrisonRevisit_Radio';
    List2.CheckpointList[33] = 'PrisonRevisit_Priest';
    List2.CheckpointList[34] = 'PrisonRevisit_Tochase';
    List2.CheckpointList[35] = 'PrisonRevisit_Chase';
    List2.CheckpointList[36] = 'Courtyard2_Start';
    List2.CheckpointList[37] = 'Courtyard2_FrontBuilding2';
    List2.CheckpointList[38] = 'Courtyard2_ElectricityOff';
    List2.CheckpointList[39] = 'Courtyard2_ElectricityOff_2';
    List2.CheckpointList[40] = 'Courtyard2_ToWaterTower';
    List2.CheckpointList[41] = 'Courtyard2_WaterTower';
    List2.CheckpointList[42] = 'Courtyard2_TopWaterTower';
    List2.CheckpointList[43] = 'Building2_Start';
    List2.CheckpointList[44] = 'Building2_Attic_Mid';
    List2.CheckpointList[45] = 'Building2_Attic_Denis';
    List2.CheckpointList[46] = 'Building2_Floor3_1';
    List2.CheckpointList[47] = 'Building2_Floor3_2';
    List2.CheckpointList[48] = 'Building2_Floor3_3';
    List2.CheckpointList[49] = 'Building2_Floor3_4';
    List2.CheckpointList[50] = 'Building2_Elevator';
    List2.CheckpointList[51] = 'Building2_Post_Elevator';
    List2.CheckpointList[52] = 'Building2_Torture';
    List2.CheckpointList[53] = 'Building2_TortureDone';
    List2.CheckpointList[54] = 'Building2_Garden';
    List2.CheckpointList[55] = 'Building2_Floor1_1';
    List2.CheckpointList[56] = 'Building2_Floor1_2';
    List2.CheckpointList[57] = 'Building2_Floor1_3';
    List2.CheckpointList[58] = 'Building2_Floor1_4';
    List2.CheckpointList[59] = 'Building2_Floor1_5';
    List2.CheckpointList[60] = 'Building2_Floor1_5b';
    List2.CheckpointList[61] = 'Building2_Floor1_6';
    List2.CheckpointList[62] = 'MaleRevisit_Start';
    List2.CheckpointList[63] = 'AdminBlock_Start';

    Foreach AllActors(Class'OLCheckpointList', FullList) {
        Foreach FullList.CheckpointList(CPName) {
            if(CPName == Name(Checkpoint)) {
                ConsoleCommand("Streammap All_Checkpoints");
                List.GameType = OGT_Outlast;
                List2.GameType = OGT_Whistleblower;
                EPHero(Pawn).Kill();
                EPHero(Pawn).RespawnHero();
                StartNewGameAtCheckpoint(Checkpoint, Save);
                List.Destroy();
                List2.Destroy();
                return;
            }
        }
    }
    SendMsg("Du hasts vermurgst...");
    List.Destroy();
    List2.Destroy();
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