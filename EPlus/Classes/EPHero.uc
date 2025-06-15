class EPHero extends OLHero;

var EPController Controller;
var EPInput Input;
Var EPPointLight Licht, LichtA;
Var OLEnemyPawn GlobalEnemy, GlobalEnemyA, ExPoseEnemy;
Var int I;
Var bool Respawning, bSee, CB1, CB2, CBOther;
Var float MessageDisplayDuration, PDamage, UnExpose;
Var string Message;
Var Name LastCP, CurrentCP;

Function PossessedBy(Controller C, Bool bVehicleTransition) 
{
    Super.PossessedBy(C, bVehicleTransition);
    Controller = EPController(C);
    Input = EPInput(Controller.Playerinput);
    if(Controller.bFB){
        FullBright(Controller.FBBrightness, Controller.FBRadius);
    }
}

Event PostBeginPlay()
{
    Super.PostBeginPlay();
    if (Class'OLUtils'.static.IsPlayingDLC()){
        SetTimer(0.017, false, 'CPController');
        SetTimer(0.02, false, 'HeroStatics');
        SetTimer(0.09, true, 'EnemyLoop');
        SetTimer(0.125, true, 'HeroLoop');
    }
    else{

    }
}

/**********Enemy Functions**********/
private Function EnemyLoop()
{
    Local OLEnemyPawn P;
    Local OLEnemyNanoCloud Walrider;
    Local OLEnemySoldier Soldier;
    Local OLBot Bot;

    // AdminEL
    if(CurrentCP =='Admin_Explosion' && !CB1)
    {
        CB1 =true;
        ET().CreateEnemy(Class'OLEnemyNanoCloud', Vect(-7128.2173, -3394.9155, 548.1500), rotation, 'EPA', false)
        .SetEnemyAttackAndDoor(300)
        .SetStaticEnemyValues()
        .nohide();
        SetTimer(0.1,true,'SubLoop');
    }
    else if(CurrentCP =='Admin_Mezzanine' && CB1)
        {CB1 =false;}
    else if(CurrentCP =='Admin_Mezzanine')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='EPA' && P.Tag !='Done')
            {
                P.Tag ='Done';
                ET(P).SetEnemySpeed(2000, 2000, 2000)
                .getEnemy()
                .SetHidden(true);
                
                ET().CreateEnemy(Class'OLEnemySoldier', Vect(-8822.4912, 643.4636, 548.1499), Rotation, 'EPA', true)
                .SetStaticEnemyValues()
                .SetEnemyAttackAndDoor(1000)
                .SetEnemySpeed(0, 0, 280)
                .SetEnemyVisionAndHearing(EVT_EPDefault)
                .SetEnemyInvestigation()
                .getEnemy()
                .Modifiers.bUseForMusic=false;
            }
        }
    }
    else if(CurrentCP =='Admin_SecurityRoom' && !CB1)
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemySoldier', Soldier)
        {
            if(Soldier.Tag !='Done')
            {
                CB1 =true;
                Soldier.Tag ='Done';
                ET(Soldier)
                .SetStaticEnemyValues()
                .SetEnemySpeed(190,700,700)
                .SetEnemyAttackAndDoor(,,,,2.0)
                .SetEnemyVisionAndHearing(EVT_EPEule, 3000);
                ExposePosition(Soldier, 5);
                SetTimer(0.3, false, 'OtherLoop');
                SetTimer(0.1, true, 'SubLoop');
                Licht =Spawn(Class'EPPointLight', , 'EPA', Vect(-6326.2437, 266.2213, -100.8500), , , true);
                Licht.SetBrightness(0.6);
                Licht.SetColor(255,0,0,255);
                Licht.SetRadius(1000);
                Licht.SetCastDynamicShadows(true);
            }
        }
    }
    else if(!CB1 && CurrentCP =='Admin_Basement')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done' && P.Modifiers.bShouldAttack)
            {
                P.Tag ='Done';
                CB1=true;
                P.SetOnlyOwnerSee(true);
                ET(P).SetStaticEnemyValues()
                .SetEnemyInvestigation(2, 200.0, 600.0, 60.0, 1200.0, 10.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 5.0, 0.0, false, false, true)
                .SetEnemyAttackAndDoor(1000.0, 200.0, 1.0, 15, 0.01, 101, 101, 101, 101, 0, 50.0)
                .SetEnemyVisionAndHearing(EVT_EPEule, 3000)
                .SetEnemySpeed(270, 800, 900);
                P.Modifiers.bUseForMusic=false;
                P.ApplyModifiers(P.Modifiers);
                GlobalEnemy =p;
                SetTimer(0.1, true, 'SubLoop');
            }
        }
    }
    // PrisonEL
    else if(CurrentCP =='Prison_Start')
    {
        if(!CB1 && InRange(Vect(3740.8137, 3969.9578, 649.9999), Location, 100))
        {
            CB1 =true;
            ET().CreateEnemy(Class'OLEnemyGenericPatient',Vect(4695.7627, 3855.5132, 648.1500), Rot(0, -32142, 0),'EPA',true)
            .SetStaticEnemyValues()
            .SetEnemyAttackAndDoor(,,,,2.0)
            .SetEnemySpeed(500,500,500)
            .SetEnemyVisionAndHearing(EVT_Normal)
            .getEnemy()
            .Modifiers.bUseForMusic=false;

            GlobalEnemy =ET().CreateEnemy(Class'OLEnemyGenericPatient',Vect(4704.3364, 3061.9988, 648.1500), Rot(0, -22954, 0),'EPB',true)
            .SetStaticEnemyValues()
            .SetEnemyAttackAndDoor(500)
            .SetEnemySpeed(800,800,800)
            .SetEnemyVisionAndHearing( EVT_Normal)
            .EquippWeapon(Weapon_Knife)
            .getEnemy();
            GlobalEnemy.Modifiers.bUseForMusic=false;
        }
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done' && P.Tag !='EPA' && P.Tag !='EPB')
            {
                P.Tag ='Done';
                ET(P).SetStaticEnemyValues()
                .SetEnemyVisionAndHearing(EVT_Normal)
                .SetEnemyAttackAndDoor(1000)
                .SetEnemySpeed(120, 900, 750)
                .SetBehavior(OLBTBehaviorTree'Prison_01-LD.02_AI_Behaviors.Generic_FullLoop_BT')
                .EquippWeapon(Weapon_knife);
                P.Modifiers.bUseForMusic=false;
                P.Modifiers.bShouldAttack=true;
            }
        }
    }
    else if(CurrentCP == 'Prison_IsolationCells01_Mid')
    {
        ET(GlobalEnemy).EnemySpeedUp(3.0);
    }
    else if(CurrentCP =='Prison_PrisonFloor_3rdFloor')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done')
            {
                if(P.ISA('OLEnemyGenericPatient_J'))
                {
                    ET(P).SetStaticEnemyValues()
                    .SetEnemySpeed(120,120,120)
                    .SetEnemyVisionAndHearing(EVT_EPEule)
                    .SetEnemyAttackAndDoor(650);
                    P.Tag ='Done';
                }
                else
                {
                    P.Tag ='Done';
                    GlobalEnemy =ET(P).SetStaticEnemyValues()
                    .SetEnemyVisionAndHearing(EVT_EPEule, 3000)
                    .SetEnemyAttackAndDoor(800)
                    .SetEnemySpeed(199,600,600)
                    .SetEnemyInvestigation(16, 400.0, 800.0, 60.0, 2000.0, 1.0, 10.0, 10.0, 10.0, 10.0, 1.0, 0.0, 10.0, 0.0, true, true, true)
                    .getEnemy();
                }
            }
            if(LocomotionMode ==LM_Locker && !IsTimerActive('SubLoop'))
            {
                SetTimer(5.0, false, 'SubLoop');
            }
        }
    }
    else if(CurrentCP =='Prison_PrisonFloor_SecurityRoom1')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            ET(P).SetStaticEnemyValues()
            .SetEnemyAttackAndDoor()
            .SetEnemySpeed(550,550,550)
            .SetBehavior(OLBTBehaviorTree'Prison_01-LD.02_AI_Behaviors.Generic_FullLoop_BT')
            .nohide()
            .EnemySpeedUp(2.0);
        }
    }
    else if(CurrentCP =='Prison_Showers_2ndFloor')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done' && P.ISA('OLEnemyGenericPatient_G'))
            {
                if(!InRange(Vect(5033.6851, 2053.8438, 998.2878), P.Location, 700))
                    {   Controller.Kill(P);}
                ET(P).SetStaticEnemyValues()
                .SetEnemySpeed(300, 345, 750)
                .SetEnemyAttackAndDoor(200.0, 200.0, 0.0,, 1.5)
                .SetEnemyVisionAndHearing(EVT_EPEule)
                .NoHide()
                .SetBehavior(OLBTBehaviorTree'Prison_01-LD.02_AI_Behaviors.Generic_FullLoop_BT');
                P.tag ='Done';
            }
            if(Specialmove ==SMT_ClimbUpLedge && P.Tag =='Done')
            {
                SetPlayerSpeed(50,100,150);
                P.SetLocation(Vect(5965.7251, -70.7976, 998.4135));
                P.SetRotation(Rot(0, 16524, 0));
                ET(P).SetEnemyAttackAndDoor(2000);
            }
        }
    }
    else if(CurrentCP =='Prison_PrisonFloor02_SecurityRoom2')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemySoldier', Soldier)
        {
            ET(Soldier).SetStaticEnemyValues()
            .SetEnemyAttackAndDoor()
            .SetEnemySpeed(1000,1000,1000)
            .NoHide()
            .EnemySpeedUp(3.75);
        }
    }
    else if(CurrentCP =='Prison_IsolationCells02_Soldier')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemySoldier', Soldier)
        {
            if(Soldier.Tag !='Done')
            {
                ET(Soldier).SetStaticEnemyValues()
                .SetEnemyAttackAndDoor(800,,,,,,,,,,1.0)
                .SetEnemySpeed(530,680,900, 220,510,565)
                .SetEnemyVisionAndHearing(EVT_EPEule, 1000)
                .SetEnemyInvestigation();
                Soldier.Tag ='Done';
            }
        }
    }
    else if(CurrentCP =='Prison_IsolationCells02_PostSoldier')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P, Vect(3455.0928, 1615.3699, 648.1500), 500)
        {
            if(P.Tag !='Done')
            {
                ET(P).SetStaticEnemyValues()
                .SetEnemyAttackAndDoor()
                .SetEnemyVisionAndHearing(EVT_Normal)
                .SetEnemySpeed(705,705,705)
                .SetBehavior(OLBTBehaviorTree'Prison_01-LD.02_AI_Behaviors.Generic_FullLoop_BT');
                P.Modifiers.bShouldAttack=true;
                P.SetOnlyOwnerSee(true);
                P.Tag ='Done';
                GlobalEnemyA =P;
            }
        }
    }
    else if(CurrentCP =='Prison_OldCells_PreStruggle' && GlobalEnemy !=None)
    {
        ET(GlobalEnemy).EnemySpeedUP(2.5)
        .NoHide();
    }
    else if(CurrentCP =='Prison_OldCells_PreStruggle2')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done')
            {
                ET(P).SetStaticEnemyValues()
                .SetEnemyInvestigation()
                .SetEnemyAttackAndDoor()
                .SetEnemySpeed(800,800,800)
                .SetEnemyVisionAndHearing(EVT_EPAlt)
                .EquippWeapon(Weapon_Knife);
                P.Tag ='Done';
            }
        }
    }
    // SewerEL
    else if(CurrentCP =='Sewer_start')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyNanoCloud', Walrider)
        {
            if(Walrider.Tag !='EPA')
            {
                Controller.Kill(Walrider);
            }
        }
        ET(GlobalEnemy).NoHide();
    }
    else if(CurrentCP =='Sewer_FlushWater' || CurrentCP =='Sewer_WaterFlushed')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemySoldier', Soldier)
        {
            if(Soldier.Tag !='Done')
            {
                Soldier.Tag ='done';
                GlobalEnemy =ET(Soldier).SetStaticEnemyValues()
                .SetEnemySpeed(325, 900, 900, 200)
                .SetEnemyVisionAndHearing(EVT_EPEule)
                .SetEnemyAttackAndDoor(900, 700)
                .SetEnemyInvestigation(16, 700.0, 1000.0, 60.0, 2000.0, 1.0, 10.0, 10.0, 10.0, 10.0, 1.0, 1.0, 5.0,,false,false,true)
                .getEnemy();
            }
        }
    }
    else if (CurrentCP =='Sewer_Citern2')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemySoldier', Soldier)
        {
            if(soldier.Tag !='done')
            {
                Soldier.Tag ='done';
                GlobalEnemy =ET(Soldier).SetStaticEnemyValues()
                .SetEnemySpeed(275, 500, 450)
                .SetEnemyVisionAndHearing(EVT_EPAlt, 1000)
                .SetEnemyAttackAndDoor(200)
                .SetEnemyInvestigation(4, 200.0, 600.0, 60.0, 1200.0, 10.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 3.0, 0.0, false, false, True)
                .getEnemy();
            }
        }
    }
    else if(CurrentCP =='Sewer_PostCitern')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            If(P.Tag !='mate' && P.IsA('OLEnemyGenericPatient_A'))
            {
                ET(P).SetStaticEnemyValues()
                .SetEnemyVisionAndHearing(EVT_EPAlt)
                .SetEnemyAttackAndDoor()
                .SetEnemySpeed(370,370,370)
                .SetEnemyInvestigation();
                P.Tag ='Mate';
            }
        }
    }
    else if(CurrentCP =='Sewer_ToMaleWard')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Mate')
            {
                P.SetCollision(false,false,false);
                Soldier =OLEnemySoldier(ET().CreateEnemy(Class'OLEnemySoldier',P.Location,P.Rotation,'Mate',true)
                .SetStaticEnemyValues()
                .SetEnemyInvestigation()
                .SetEnemySpeed(450,500,750)
                .SetEnemyVisionAndHearing(EVT_Normal)
                .getEnemy());
                if(InRange(Vect(-1030.0917, -8681.7715, -846.3397), Soldier.Location, 300))
                {
                    ET(Soldier).SetEnemyAttackAndDoor();
                }
                else
                {
                    ET(Soldier).SetEnemyAttackAndDoor(,200,,,4);
                }
                Controller.Kill(P);
            }
        }
    }
    // MaleEL
    else if(CurrentCP =='Male_Chase')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done')
            {
                ET(P).SetStaticEnemyValues()
                .SetEnemyAttackAndDoor(,,,,,,,,,,50)
                .SetEnemySpeed(500,500,500);
                P.Tag ='Done';
            }
        }
    }
    else if(CurrentCP =='Male_ChasePause')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done' && P.Modifiers.bShouldAttack)
            {
                if(I==0)
                {
                    Controller.Kill(P);
                    I++;
                    continue;
                }
                else if(I ==1)
                {
                    P.SetLocation(Vect(-3373.0918, -9307.4551, -451.8500));
                    P.SetRotation(Rot(0, 32315, 0));
                    ET(P).SetStaticEnemyValues()
                    .SetEnemyAttackAndDoor()
                    .SetEnemySpeed(120,120,120);
                    P.Tag ='done';
                    I++;
                    Continue;
                }
                ET(P).SetStaticEnemyValues()
                .SetEnemyAttackAndDoor()
                .SetEnemySpeed(350,350,350);
                P.SetLocation(Vect(-142.7476, -7236.9209, -451.8500));
                P.Tag ='Done';
                GlobalEnemy =P;
            }
        }
        ET(GlobalEnemy).EnemySpeedUp(3);
        if(InRange(Vect(-1982.3485, -9303.4063, -451.8500), Location, 300))
        {   ET(GlobalEnemy).SetEnemySpeed(650,650,650);}
    }
    else if(CurrentCP =='Male_TortureDone')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done')
            {
                OtherLoop();
                Controller.SetGameSpeed ();
                ET(P).SetStaticEnemyValues()
                .SetEnemyInvestigation()
                .SetEnemyAttackAndDoor(1000)
                .SetEnemyVisionAndHearing(EVT_EPEule)
                .SetEnemySpeed(800, 800, 900);
                P.SetOnlyOwnerSee(true);
                GlobalEnemy =P;
                P.Tag ='Done';
            }
        }
        ET(GlobalEnemy).EnemySpeedUp(4);
    }
    else if(CurrentCP =='Male_Surgeon')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='done')
            {
                ET(P).SetStaticEnemyValues()
                .SetEnemyInvestigation()
                .SetEnemyAttackAndDoor(1000)
                .SetEnemyVisionAndHearing(EVT_EPEule)
                .SetEnemySpeed(200, 800, 850);
                P.SetOnlyOwnerSee(true);
                GlobalEnemy =P;
                ExposePosition(GlobalEnemy, 20);
                P.Tag ='Done';
            }
        }
    }
    else if(CurrentCP =='Male_GetTheKey2')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if (P.Tag !='Done')
            {
                ET(P).SetStaticEnemyValues()
                .SetEnemyInvestigation()
                .SetEnemyAttackAndDoor(200)
                .SetEnemyVisionAndHearing(EVT_EPEule)
                .SetEnemySpeed(325, 800, 850);
                P.SetOnlyOwnerSee(true);
                P.Tag ='Done';
                GlobalEnemy =P;
            }
        }
    }
    else if(CurrentCP =='Male_SprinklerOff')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemySoldier', Soldier)
        {
            if(Soldier.Tag !='Done')
            {
                ET(Soldier).SetStaticEnemyValues()
                .SetEnemyInvestigation()
                .SetEnemyAttackAndDoor(,300,,,4.0)
                .SetEnemyVisionAndHearing(EVT_EPAlt);
                if(!CB1)
                {    ET(Soldier).SetEnemySpeed(240, 500, 650);}
                else
                {   ET(Soldier).SetEnemySpeed(240, 325, 500);}
                Soldier.Tag ='Done';
                GlobalEnemy =Soldier;
            }
        }
        ET(GlobalEnemy).EnemySpeedUp(2);
        if(!CB1 && LocomotionMode ==LM_Cinematic && InRange(Vect(-6117.5894, -11233.1787, -1.8500), Location, 200))
        {   CB1 =true;}
    }
    // Courtyard EL
    else if(CurrentCP =='Courtyard_Corridor')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='EPA')
            {
                P.Tag='EPA';
                P.SetOnlyOwnerSee(true);
                P.SetCollision(false,false,false);
                ET(P).SetEnemySpeed(900,900,900);
                GlobalEnemy =ET().CreateEnemy(Class'OLEnemyNanoCloud',P.Location,P.Rotation,'EPA',true)
                .SetStaticEnemyValues()
                .SetEnemySpeed(,,500,750)
                .SetEnemyInvestigation()
                .SetEnemyAttackAndDoor(200,200)
                .SetEnemyVisionAndHearing(EVT_EPAlt)
                .getEnemy();
            }
        }    
    }
    else if(CurrentCP =='Courtyard_Soldier1')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemySoldier', Soldier)
        {
            if(Soldier.Tag !='Done')
            {
                Soldier.SetOnlyOwnerSee(true);
                Soldier.Tag ='Done';                
                ET(Soldier).SetStaticEnemyValues()
                .SetEnemySpeed(750,750,750)
                .SetEnemyAttackAndDoor(800)
                .Nohide();
            }
        }
    }
    else if(CurrentCP =='Courtyard_Soldier2')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemySoldier', Soldier)
        {
            if(Soldier.Tag !='Done')
            {
                Soldier.SetOnlyOwnerSee(true);
                Soldier.Tag ='Done';                
                ET(Soldier).SetStaticEnemyValues()
                .SetEnemyVisionAndHearing(EVT_EPAlt,1500)
                .SetEnemyInvestigation()
                .SetEnemySpeed(190,750,750)
                .SetEnemyAttackAndDoor(800);
            }
        }
    }
    // Female EL
    else if(CurrentCP =='Female_2ndFloor' || CurrentCP =='Female_2ndfloorChute')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(!CB1 && P.ISA('OLEnemyGenericPatient_B'))
            {
                P.SetOnlyOwnerSee(true);
                GlobalEnemy =ET(P).SetStaticEnemyValues()
                .SetEnemySpeed(350, 750, 850)
                .SetEnemyVisionAndHearing(EVT_EPEule)
                .SetEnemyAttackAndDoor(1000)
                .SetEnemyInvestigation()
                .getEnemy();
                CB1 =true;
                SetTimer(5, false, 'PCH');
                Controller.SetGameSpeed();
            }
            if(CB1)
            {
                ET(GlobalEnemy).EnemySpeedUp(4);
                GlobalEnemy.SetCollision(false,false,false);
                if((SpecialMove ==SMT_JumpOver || SpecialMove ==SMT_ClimbUpObstacle) && InRange(Vect(-3579.3215, 9468.1504, 548.2580), Location, 200))
                { 
                    SetLocation(GlobalEnemy.Location+Vect(0,0,40));
                    SetRotation(GlobalEnemy.Rotation);
                    SetPlayerSpeed(0,0,0);
                    InitBMSG("CHEATER!!!", SoundCue'EPlusAssets.Sound.Walrider_Angry_short_Cue', 3.5, 0.1);
                }
                if(!ISTimerActive('PCH'))
                {
                    DMGS(7);
                    SetTimer(5, false, 'PCH');
                }
                if(LocomotionMode ==LM_Bed || LocomotionMode ==LM_Locker)
                {   SetJumpPunishment(101,1);}
                else
                {   SetJumpPunishment(101,100);}
            }
        }        
    }
    else if(CurrentCP =='Female_ChuteActivated')
    {
        if(CB1)
        {
            CB1 =false;
            GlobalEnemyA =ET().CreateEnemy(Class'OLEnemyGroom',Vect(-3326.8953, 8845.6758, 350.1505),Rot(0, -17909, 0),,true)
            .SetStaticEnemyValues()
            .SetEnemySpeed(750,750,750)
            .SetEnemyAttackAndDoor(,200)
            .getEnemy();
            ET(GlobalEnemy).SetEnemyAttackAndDoor(1000,200,,,,,,30);
            ExposePosition(GlobalEnemyA, 600);
        }
        ET(GlobalEnemyA).EnemySpeedUp(2);
    }
    else if(CurrentCP =='Female_KeyPickedup' || CurrentCP =='Female_3rdFloor')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done' && !P.ISA('OLEnemyGenericPatient_G'))
            {
                GlobalEnemy =ET(P).SetStaticEnemyValues()
                .SetEnemySpeed(400, 750, 750)
                .SetEnemyVisionAndHearing(EVT_EPAlt)
                .SetEnemyAttackAndDoor(1000, 200)
                .SetEnemyInvestigation()
                .getEnemy();
                P.SetOnlyOwnerSee(true);
                P.Tag ='Done';
            }
        }
        ET(GlobalEnemy).EnemySpeedUp(4);
    }
    else if(CurrentCP =='Female_3rdFloorPosthole')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done' && P.IsA('OLEnemyGenericPatient_G'))
            {
                P.SetCollision(false,false,false);
                ET(P).SetStaticEnemyValues()
                .SetEnemySpeed(700, 750,750)
                .SetEnemyVisionAndHearing(EVT_EPEule)
                .SetEnemyAttackAndDoor(1000,200)
                .SetEnemyInvestigation();
                P.SetOnlyOwnerSee(true);
                P.SetLocation(Vect(-6348.9712, 10545.0332, 998.1505));
                P.Tag ='Done';
            }
        }
    }
    else if(CurrentCP =='Female_LostCam')
    {   ET(GlobalEnemy).EnemySpeedUp(4);}
    else if(CurrentCP =='Female_FoundCam')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done' && P.Modifiers.bShouldAttack)
            {
                if(!CB1)
                {  
                    Controller.Kill(P);
                    CB1=true;
                    continue;
                }
                ET(P).SetStaticEnemyValues()
                .SetEnemySpeed(480,480,480)
                .SetEnemyAttackAndDoor()
                .SetEnemyVisionAndHearing(EVT_EPEule);
                P.Tag ='Done';
            }
        }
    }
    else if(CurrentCP =='Female_Jump')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.tag !='Done')
            {
                ET(P).SetStaticEnemyValues()
                .SetEnemyVisionAndHearing(EVT_EPAlt)
                .SetEnemyInvestigation()
                .SetEnemySpeed(120,150,450)
                .SetEnemyAttackAndDoor()
                .SetBehavior(OLBTBehaviorTree'Prison_01-LD.02_AI_Behaviors.Generic_FullLoop_BT');
                P.Modifiers.bShouldAttack =true;
                P.Tag ='Done';
            }
        }
    }
    // Revisit EL
    else if(CurrentCP =='Revisit_Soldier1')
    {
        ForEach WorldInfo.AllPawns(Class'OLenemySoldier', Soldier)
        {
            if(Soldier.Tag !='Done')
            {
                ET(Soldier).SetStaticEnemyValues()
                .SetEnemySpeed(250, 600, 650)
                .SetEnemyVisionAndHearing(EVT_EPEule)
                .SetEnemyInvestigation()
                .SetEnemyAttackAndDoor(800,500);
                Soldier.Tag ='Done';
            }
            ET(Soldier).EnemySpeedUp(2.5);
        }
    }
    else if(CurrentCP =='Revisit_Mezzanine')
    {   ET(GlobalEnemy).EnemySpeedUp(3.5);}
    else if(CurrentCP =='Revisit_RH')
    {   ET(GlobalEnemy).EnemySpeedUp(1.75);}
    else if(CurrentCP =='Revisit_FoundKey')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done' && P.IsA('OLEnemyGenericPatient_G'))
            {
                ET(P).SetStaticEnemyValues()
                .SetEnemyVisionAndHearing(EVT_EPEule)
                .SetEnemyAttackAndDoor(1000)
                .SetEnemySpeed(900,900,900)
                .SetEnemyInvestigation();
                P.SetOnlyOwnerSee(true);
            }
            ET(P).EnemySpeedUp(2.5);
        }
    }
    else if(CurrentCP =='Revisit_Soldier3')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemySoldier', Soldier)
        {
            if(Soldier.Tag !='Done')
            {
                ET(Soldier).SetStaticEnemyValues()
                .SetEnemySpeed(530,680,900,,,565)
                .SetEnemyAttackAndDoor(800);
                Soldier.SetOnlyOwnerSee(true);
                ExposePosition(Soldier, 20);
                Soldier.Tag ='Done';
            }
        }
    }
    // Lab EL
    else if(CurrentCP =='Lab_SwarmIntro2')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyNanoCloud', Walrider)
        {
            if(Walrider.Tag !='Done')
            {
                ET(Walrider).SetEnemySpeed(10,10,10)
                .SetEnemyAttackAndDoor(,200,0.0,0.0,3600,0.0, 0.0, 0.0, 0.0,0);
                Walrider.AttackNormalKnockbackPower = 0;
                Walrider.Modifiers.bShouldAttack =false;
                Walrider.Tag ='Done';
            }
        }
    }
    else if(CurrentCP =='Lab_SwarmCafeteria')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyNanoCloud', Walrider)
        {
            if(Walrider.Tag !='Done')
            {
                Walrider.Modifiers.bShouldAttack =true;
                GlobalEnemy =ET(Walrider).SetStaticEnemyValues()
                .SetEnemyAttackAndDoor(500)
                .SetEnemySpeed(900,400,750)
                .SetEnemyInvestigation()
                .SetEnemyVisionAndHearing(EVT_EPEule)
                .getEnemy();
                Walrider.Tag ='Done';
            }
        }
    }
    else if(CurrentCP =='Lab_BigRoomDone')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyNanoCloud', Walrider)
        {
            if(Walrider.Tag !='Done')
            {
                ET(Walrider).SetStaticEnemyValues()
                .SetEnemyAttackAndDoor(200)
                .SetEnemySpeed(500,500,500);
                Walrider.SetCollision(false,false,false);
            }
        }
    }
    else if(CurrentCP =='Lab_BigTowerStairs')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag =='Dodge')
            {   Controller.Kill(P); Continue;}
            if(P.IsA('OLEnemyNanoCloud_A'))
            {
                Controller.Kill(P);
                GlobalEnemy =ET().CreateEnemy(Class'OLEnemyNanoCloud',P.Location,P.Rotation,'FastFertig',true)
                .SetStaticEnemyValues()
                .SetEnemyVisionAndHearing(EVT_EPEule)
                .SetEnemyAttackAndDoor(200)
                .SetEnemySpeed(,,450)
                .getEnemy();
                Continue;
            }
            if(GlobalEnemy !=None && InRange(Vect(-26593.3398, 1898.1426, -891.8499), Location, 70))
            {   Controller.Kill(GlobalEnemy);}
            if(P.Tag !='FastFertig')
            {
                ET(P).SetStaticEnemyValues()
                .SetEnemyAttackAndDoor(200)
                .SetEnemySpeed(500,500,500);
                P.Tag ='FastFertig';
            }
        }
    }
    else if(CurrentCP =='Lab_BigTowerDone')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyNanoCloud',Walrider)
        {
            Controller.Kill(Walrider);
        }
    }
}

Function SubLoop()
{
    Local OLEnemyPawn P;
    Local OLBot Bot;
    Local EPPointLight EPL;

    // AdminESL
    if(CurrentCP =='Admin_Explosion')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            switch(I)
            {
                case 0:
                    P.SetLocation(Vect(-7051.7231, -3859.7966, 548.1500));
                    I=1;
                    break;
                case 1:
                    p.SetLocation(Vect(-7030.0376, -3297.3965, 548.1500));
                    I=2;
                    break;
                case 2:
                    P.SetLocation(Vect(-7082.0571, -1970.1903, 548.1500));
                    I=3;
                    break;
                case 3:
                    P.SetLocation(Vect(-7086.6860, -1226.2305, 548.1400));
                    I=4;
                    break;
                case 4:
                    P.SetLocation(Vect(-7430.4839, -1580.2310, 636.6907));
                    I=5;
                    break;
                case 5:
                    P.SetLocation(Vect(-7086.6860, -1226.2305, 548.1400));
                    I=6;
                    break;
                case 6:
                    p.SetLocation(Vect(-7082.0571, -1970.1903, 548.1500));
                    I=7;
                    break;
                case 7:
                    P.SetLocation(Vect(-7030.0376, -3297.3965, 548.1500));
                    I=8;
                    break;
                case 8:
                    P.SetLocation(Vect(-7051.7231, -3859.7966, 548.1500));
                    I=0;
                    break;
            }
        }
        if(InRange(Vect(-6790.3335, -3478.0862, 548.0833), Location, 300) && GetTimerRate('SubLoop') != 0.2)
        {
            ClearTimer('SubLoop');
            SetTimer(0.2, true, 'SubLoop');
            // Controller.CPAEnabled =true;
        }
        else if(InRange(Vect(-6932.3936, -2432.6907, 548.1500), Location, 500) && GetTimerRate('SubLoop') !=0.4)
        {
            ClearTimer('SubLoop');
            SetTimer(0.4, true, 'SubLoop');
        }
        else if(InRange(Vect(-7598.5928, -1463.3639, 853.1500), Location, 100))
        {
            Controller.Kill();
            ClearTimer('SubLoop');
            I =0;
        }
    }
    else if(CurrentCP =='Admin_SecurityRoom')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            ET(P).EnemySpeedUp(3.75);
        }
        if(InRange(Licht.Location, Location, 200) && !CB2)
        {
            CB2 =true;
            ForEach AllActors(Class'EPPointLight', EPL)
            {
                if(EPL.Tag =='EPA')
                    {EPL.Destroy();}
            }
            PlaySound(SoundCue'EPlusAssets.Sound.Walrider_Angry_short_Cue',,,,Vect(-6729.4019, -870.7884, -651.8499));
            GlobalEnemy =ET().CreateEnemy(Class'OLEnemyNanoCloud',Vect(-6729.4019, -870.7884, -651.8499),Rotation,,true)
            .SetStaticEnemyValues()
            .SetEnemyAttackAndDoor(200)
            .SetEnemySpeed(700,700,420)
            .noHide()
            .getEnemy();
        }
    }
    else if(CurrentCP =='Admin_Basement')
    {
        ET(GlobalEnemy).EnemySpeedUp(2.5);
        if(!CB2 && InRange(Vect(-6505.2329, 2924.3276, -551.8500), Location, 120))
        {
            ET(GlobalEnemy).SetEnemySpeed(201, 700, 800, 201, 750, 900);
            CB2 =true;
        }
    }
    // PrisonESL
    else if(CurrentCP =='Prison_PrisonFloor_3rdFloor')
    {
        ExposePosition(GlobalEnemy, 1);
    }
    else if(CurrentCP =='Prison_OldCells_PreStruggle')
    {
        GlobalEnemy =ET().CreateEnemy(Class'OLEnemyGenericPatient',Vect(3596.1333, 1991.8582, 998.1500), Rot(0, -17708, 0),'EPA',true)
        .SetStaticEnemyValues()
        .SetEnemyAttackAndDoor( 300,,,,1.0)
        .SetEnemySpeed(400,400,800)
        .EquippWeapon(Weapon_Machete)
        .getEnemy();
    }
    // SewerESL
    else if(CurrentCP =='Sewer_start')
    {
        GlobalEnemy =ET().CreateEnemy(Class'OLEnemyNanoCloud',Vect(4406.8799, 4585.3325, -401.8301),Rot(0, -17239, 0),'EPA',true)
        .SetStaticEnemyValues()
        .SetEnemySpeed(520,520,520)
        .SetEnemyAttackAndDoor(800.0,   250.0, 1.0, 15, 0.01, 0.0, 0.0, 0.0, 0.0, 0, 3)
        .SetBehavior(OLBTBehaviorTree'02_AI_Behaviors.Soldier_BT')
        .getEnemy();
    }
    else if(CurrentCP =='Sewer_PostCitern')
    {
        GlobalEnemy =ET().CreateEnemy(Class'OLEnemyGenericPatient',Vect(-3291.5776, -5156.1479, -401.8497), Rot(0, -18215, 0),'Mate',true)
        .SetStaticEnemyValues()
        .SetEnemySpeed(500,500,500)
        .SetEnemyAttackAndDoor()
        .EquippWeapon(Weapon_Knife)
        .NoHide()
        .getEnemy();
    }
    // Male ESL
    // Courtyard ESL
    // Female ESL
    else if(CurrentCP =='Female_LostCam')
    {
        GlobalEnemy =ET().CreateEnemy(Class'OLEnemyGenericPatient',Vect(-4803.6523, 9873.1973, 548.1505),Rot(0, -15158, 0),'Done',true)
        .SetStaticEnemyValues()
        .SetEnemySpeed(700,700,700)
        .SetEnemyVisionAndHearing(EVT_EPEule, 10000)
        .SetEnemyAttackAndDoor(,200)
        .EquippWeapon(Weapon_Knife)
        .getEnemy();
    }
    else if(CurrentCP =='Female_FoundCam' && CB1)
    {
        ClearTimer('SubLoop');
        InitBMSG("Survive for 40sec!",SoundCue'EPlusAssets.Sound.PopUp_Cue', 3, 0.1);
        SetTimer(40, false, 'PCH');
        SetTimer(0.1, true, 'HeroSubLoop');
    }
    // Revisit ESL
    else if(CurrentCP =='Revisit_Mezzanine')
    {
        GlobalEnemy =ET().CreateEnemy(Class'OLEnemyGroom',Vect(-7325.9512, 749.8629, 550.0381),Rot(0, -24696, 0),'EPA',true)
        .SetStaticEnemyValues()
        .SetEnemyVisionAndHearing(EVT_EPEule)
        .SetEnemySpeed(,700,800)
        .SetEnemyInvestigation()
        .SetEnemyAttackAndDoor()
        .getEnemy();
    }
    else if(CurrentCP =='Revisit_RH' && Inrange(Vect(-5461.3047, 437.6146, 365.1656), Location, 110))
    {
        ClearTimer('SubLoop');
        GlobalEnemy =ET().CreateEnemy(Class'OLEnemyNanoCloud',Vect(-4458.0947, 901.7354, 365.1656),Rot(0, -32746, 0),,true)
        .SetStaticEnemyValues()
        .SetEnemySpeed(1000,1000,1000)
        .SetEnemyAttackAndDoor()
        .NoHide()
        .getEnemy();
    }
    else if(CurrentCP =='Lab_BigRoomDone')
    {
        ET().CreateEnemy(Class'OLEnemySoldier',Vect(-23377.5762, -5673.4341, -4301.8501),Rot(0, -17632, 0),'Dodge',true).SetStaticEnemyValues().SetEnemySpeed(0,10,450).SetEnemyAttackAndDoor().SetEnemyVisionAndHearing(EVT_EPEule).SetEnemyInvestigation();
        ET().CreateEnemy(Class'OLEnemySoldier',Vect(-23850.9941, -4863.2378, -4301.8496),Rot(0, -6619, 0),'Dodge',true).SetStaticEnemyValues().SetEnemySpeed(0,10,450).SetEnemyAttackAndDoor().SetEnemyVisionAndHearing(EVT_EPEule).SetEnemyInvestigation();
        ET().CreateEnemy(Class'OLEnemySoldier',Vect(-23248.8262, -2088.1570, -4301.8501),Rot(0, -21109, 0),'Dodge',true).SetStaticEnemyValues().SetEnemySpeed(0,10,450).SetEnemyAttackAndDoor().SetEnemyVisionAndHearing(EVT_EPEule).SetEnemyInvestigation();                
        ET().CreateEnemy(Class'OLEnemySoldier',Vect(-24142.0098, -612.3654, -4121.1729),Rot(0, -7365, 0),'Dodge',true).SetStaticEnemyValues().SetEnemySpeed(0,10,450).SetEnemyAttackAndDoor().SetEnemyVisionAndHearing(EVT_EPEule).SetEnemyInvestigation();
    }
    else if(CurrentCP =='Lab_BigTowerDone')
    {
        for(i =0; i<10; i++)
        {
            GlobalEnemy=ET().CreateEnemy(Class'OLEnemySurgeon',Vect(-24995.2031, 1083.2507, -3751.8501),Rotation,'Meme',false)
            .SetStaticEnemyValues()
            .SetEnemySpeed(500,500,500)
            .SetEnemyAttackAndDoor(,200,0.0,0.0,0.01,0.0, 0.0, 0.0, 0.0,0)
            .NoHide()
            .EnemyAnimRate(2)
            .getEnemy();
            GlobalEnemy.AttackNormalKnockbackPower =0;
        }
    }
}

// Hero loops

private Function HeroLoop()
{
    // AdminHL
    if(validateCP('Admin_Gates'))
    {
        SetTimer(0.5, false, 'HeroSubLoop');
        SetPlayerSpeed();
        SetJumpPunishment();
    }
    else if(validateCP('Admin_Mezzanine'))
    {
        SetJumpPunishment(90, 20);
        SetPlayerSpeed(,,330);
        SetTimer(0.1, true, 'HeroSubLoop');
    }
    else if(validateCP('Admin_MainHall') || validateCP('Admin_WheelChair'))
    {
        SetJumpPunishment();
        SetPlayerSpeed();
        Controller.SetGameSpeed(3);
        if(CurrentCP =='Admin_WheelChair')
        {
            SetTimer(0.2, true, 'HeroSubLoop');
        }
    }
    else if(validateCP('Admin_Securityroom'))
    {
        SetJumpPunishment(95, 8);        
        SetPlayerSpeed(50,110,330);
    }
    else if(validateCP('Admin_Basement'))
    {
        CB1 =false;
        CB2 =false;
        ClearTimer('SubLoop');
        Controller.Kill();
        SetPlayerSpeed(50, 110, 330);
        SetJumpPunishment(101, 10);        
        SetTimer(2.0, false, 'OtherLoop');
    }
    else if(validateCP('Admin_PostBasement'))
    {
        CB1 =false;
        CB2 =false;
        ClearTimer('SubLoop');
        ClearTimer('HeroSubLoop');
        SetPlayerSpeed(,,700);
        SetJumpPunishment();
    }
    // PrisonHL
    else if(validateCP('Prison_Start'))
    {
        SetPlayerSpeed(50, 110, 330,);
        SetJumpPunishment(101, 10);
        SetTimer(0.2, true, 'HeroSubLoop');
    }
    else if(validateCP('Prison_ToPrisonFloor'))
    {
        SetPlayerSpeed();
        SetJumpPunishment();
        CB1 =false;
        ClearTimer('HeroSubLoop');
        Controller.Kill();
        Controller.bHasCamcorder=false;
        SetTimer(0.5, false, 'HeroSubLoop');
    }
    else if(validateCP('Prison_PrisonFloor_3rdFloor'))
    {
        SetJumpPunishment(101, 0.02);
        SetPlayerSpeed(50,110,350);
        Controller.bHasCamcorder=true;
        Controller.SetGrainBrightness();
        SetTimer(0.3, true, 'HeroSubLoop');
    }
    else if(validateCP('Prison_PrisonFloor_SecurityRoom1'))
    {
        SetJumpPunishment(101, 10);
        SetPlayerSpeed(50,110,350);
        SetTimer(2, false, 'OtherLoop');
    }
    else if(validateCP('Prison_PrisonFloor02_IsolationCells01'))
    {
        SetJumpPunishment(101, 10);
        SetPlayerSpeed(50,110,240);
        Cb1 =false;
        CB2 =false;
        Controller.bCPActive=false;
        InitAmpel();
    }
    else if(validateCP('Prison_Showers_2ndFloor'))
    {
        SetJumpPunishment(101, 10);
        SetPlayerSpeed(50,110,330);
        InitAmpel(false);
    }
    else if(validateCP('Prison_PrisonFloor02_PostShowers'))
    {
        SetJumpPunishment(0, 10);
        SetPlayerSpeed();
        Controller.SetGameSpeed(2.5);
    }
    else if(validateCP('Prison_PrisonFloor02_SecurityRoom2'))
    {
        Controller.SetGameSpeed();
        SetJumpPunishment(60, 8);
        SetPlayerSpeed(55, 110, 300);
        SetTimer(1, false, 'OtherLoop');
    }
    else if(validateCP('Prison_IsolationCells02_Soldier'))
    {
        SetJumpPunishment(60, 6);
        SetPlayerSpeed(55, 110, 350);
    }
    else if(validateCP('Prison_IsolationCells02_PostSoldier'))
    {
        SetJumpPunishment(101, 2);
        SetPlayerSpeed(55, 110, 330);
        SetTimer(3, false, 'OtherLoop');
    }
    else if(validateCP('Prison_OldCells_PreStruggle'))
    {
        SetJumpPunishment(90, 5);
        SetPlayerSpeed(55, 110, 330);
        SetTimer(0.025, false, 'OtherLoop');
        SetTimer(0.2, true, 'HeroSubLoop');
        if(GlobalEnemyA !=None)
        {   Controller.Kill(GlobalEnemyA);}
    }
    else if(validateCP('Prison_OldCells_PreStruggle2'))
    {
        SetJumpPunishment(101, 0.02);
        SetPlayerSpeed(75,200,200);
        SetTimer(1, false, 'OtherLoop');
        if(GlobalEnemy !=None)
        {
            Controller.Kill(GlobalEnemy);
        }
    }
    else if(validateCP('Prison_Showers_Exit'))
    {
        SetJumpPunishment();
        SetPlayerSpeed();
        SetTimer(1, false, 'OtherLoop');
        Controller.Kill();
    }
    // SewerHL
    else if(validateCP('Sewer_start'))
    {
        SetJumpPunishment(101,0.02);
        SetPlayerSpeed(55,110,330);
        SetTimer(3, false, 'SubLoop');
    }
    else if(validateCP('Sewer_FlushWater'))
    {
        SetJumpPunishment(101,0.02);
        SetPlayerSpeed(55,110,330);
        if(GlobalEnemy !=None)
        {   Controller.Kill(GlobalEnemy);}
        SetTimer(1, false, 'OtherLoop');
        SetTimer(0.2, true, 'HeroSubLoop');
    }
    else if(validateCP('Sewer_Ladder') || validateCP('Sewer_ToCitern') || validateCP('Sewer_Citern1'))
    {
        SetJumpPunishment();
        SetPlayerSpeed(120);
        CB1 =false; CB2 =false; CBOther =false;
        ClearTimer('HeroSubLoop');
        ClearTimer('StartBonus');
        ClearTimer('NoBonus');
        Controller.SetGameSpeed(1.5);
    }
    else if(validateCP('Sewer_Citern2'))
    {
        SetJumpPunishment(101, 0.02);
        SetPlayerSpeed(,,330);
        Controller.SetGameSpeed();
        SetTimer(0.1, true, 'HeroSubLoop');
    }
    else if(validateCP('Sewer_PostCitern'))
    {
        if(GlobalEnemy !=None)
        {   Controller.Kill(GlobalEnemy);}
        if(IsTimerActive('HeroSubLoop'))
        {   ClearTimer('HeroSubLoop');}
        SetJumpPunishment(101, 0.02);
        SetPlayerSpeed(55,110,370);
        SetTimer(0.5, false, 'SubLoop');
    }
    else if(validateCP('Sewer_ToMaleWard'))
    {
        ClearTimer('SubLoop');
        if(GlobalEnemy !=None)
        {   GlobalEnemy.modifiers.bShouldAttack =false;}
        SetPlayerSpeed();
        // 68 Jahre...
        SetJumpPunishment(35, MaxInt);
    }
    // MaleHL
    else if(validateCP('Male_Start'))
    {
        Controller.Kill();
        SetPlayerSpeed();
        SetJumpPunishment();
    }
    else if(validateCP('Male_Chase'))
    {
        SetPlayerSpeed(55, 110, 350);
        SetJumpPunishment(101, 0.02);
        SetTimer(1, false, 'OtherLoop');
        SetTimer(0.1, true, 'HeroSubLoop');
    }
    else if(validateCP('Male_ChasePause'))
    {
        SetPlayerSpeed(55, 110, 330);
        SetJumpPunishment(1, 0.02);
        SetTimer(0.15, false,'HeroSubLoop');
        SetTimer(1, false, 'OtherLoop');
    }
    else if(validateCP('Male_Torture'))
    {
        I =0;
        Healing(MaxInt, 0.02);
        if(EPGame(WorldInfo.Game).DifficultyMode !=EDM_Insane)
        {
            InitBMSG("LeftClick to skip cutscene.", SoundCue'EPlusAssets.Sound.PopUp_Cue', 15, 0.2);
            SetTimer(1, false, 'HeroSubLoop');
        }
    }
    else if(validateCP('Male_TortureDone'))
    {
        if(GlobalEnemy !=none)
        {   Controller.Kill(GlobalEnemy);}
        ClearTimer('HeroSubLoop');
        if(EPHud(Controller.Hud).DisplayMsg)
        {   EPHud(Controller.Hud).DisplayMsg =false;}
        SetPlayerSpeed(55, 110, 330);
        SetJumpPunishment(101, 0.02);
        Controller.bHasCamcorder =false;
        Controller.SetGameSpeed(3);
    }
    else if(validateCP('Male_Surgeon'))
    {
        if(GlobalEnemy !=none)
        {   Controller.Kill(GlobalEnemy);}
        SetPlayerSpeed(55, 110, 350);
        SetJumpPunishment(101, 0.02);
        Controller.bHasCamcorder =false;
        SetTimer(0.1, true, 'HeroSubLoop');
        SetTimer(1, false, 'OtherLoop');
    }
    else if(validateCP('Male_GetTheKey'))
    {
        if(GlobalEnemy !=none)
        {   Controller.Kill(GlobalEnemy);}
        if(IsTimerActive('HeroSubLoop'))
        {   ClearTimer('HeroSubLoop');}
        SetPlayerSpeed(55, 110, 330);
        SetJumpPunishment(101, 0.02);
        Controller.bHasCamcorder =false;
        SetTimer(0.1, false, 'OtherLoop');
    }
    else if(validateCP('Male_ElevatorDone') || validateCP('Male_Priest') || validateCP('Male_Cafeteria'))
    {
        SetPlayerSpeed(,,850);
        SetJumpPunishment();
        Controller.bHasCamcorder =true;
        if(CurrentCP =='Male_Cafeteria')
        {   SetTimer(0.1, true, 'HeroSubLoop');}
    }
    else if(validateCP('Male_SprinklerOff'))
    {
        CB1 =false;
        SetPlayerSpeed(55,110,350);
        SetJumpPunishment(60, 4);
        SetTimer(1, false, 'OtherLoop');
        SetTimer(160, false, 'KillSelf');
        SetTimer(0.1, true, 'HeroSubLoop');
    }
    else if(validateCP('Male_SprinklerOn'))
    {   
        SetJumpPunishment(101,0.02);
        if(GlobalEnemy !=None)
        {   
            ET(GlobalEnemy).SetEnemyAttackAndDoor(1000)
            .SetEnemySpeed(240,500,800)
            .SetEnemyVisionAndHearing(EVT_EPEule);
        }
    }
    // Courtyard HL
    // Apply default Values
    else if(validateCP('Courtyard_Start') || validateCP('Courtyard_Corridor') || validateCP('Courtyard_Chapel') || validateCP('Courtyard_FemaleWard') || validateCP('Female_Start') || validateCP('Admin_Garden') || validateCP('Admin_Explosion') || validateCP('Female_Chasedone') || validateCP('Female_Exit') || validateCP('Revisit_ToLab') || validateCP('Lab_BigTowerMid'))
    {
        SetPlayerSpeed();
        SetJumpPunishment();
    }
    else if(validateCP('Courtyard_Soldier1'))
    {
        if(GlobalEnemy !=None)
        {   Controller.Kill(GlobalEnemy);}
        SetPlayerSpeed(55,110,330);
        SetJumpPunishment(99,10);
    }
    else if(validateCP('Courtyard_Soldier2'))
    {
        SetPlayerSpeed(55,110,350);
        SetJumpPunishment(101,0.02);
    }
    else if(validateCP('Female_Mainchute'))
    {
        SetPlayerSpeed(55,110,350);
        SetJumpPunishment(101,0.02);
        bHobbling =true;
    }
    else if(validateCP('Female_2ndFloor') || validateCP('Female_2ndfloorChute'))
    {
        SetPlayerSpeed(55,110,330);
        SetJumpPunishment(101,100);
        bHobbling =false;
        SetTimer(1, false,'OtherLoop');
        Controller.SetGameSpeed(2);
    }
    else if(validateCP('Female_ChuteActivated'))
    {
        SetJumpPunishment(101,0.02);
        SetPlayerSpeed(55,110,370);
        Controller.AIChaseMusicTimeDelay =0.5;
        Controller.AIChaseMusicTimer =0.4;
    }
    else if(validateCP('Female_Keypickedup'))
    {
        SetJumpPunishment(101,0.02);
        SetPlayerSpeed(55,110,330);
        Controller.AIChaseMusicTimeDelay =MaxInt;
        SetTimer(0.2, true, 'HeroSubLoop');
        SetTimer(1, false,'OtherLoop');
        if(GlobalEnemyA !=None)
        {   Controller.Kill(GlobalEnemyA);}
    }
    else if(validateCP('Female_3rdFloor'))
    {
        bHobbling =true;
        SetPlayerSpeed();
        SetJumpPunishment(101,0.02);
        SetTimer(1, false, 'OtherLoop');
        SetTimer(0.1, true, 'HeroSubLoop');
    }
    else if(validateCP('Female_3rdFloorHole'))
    {
        bHobbling =false;
        SetPlayerSpeed();
        SetJumpPunishment();
        if(IsTimerActive('HeroSubLoop'))
        {   ClearTimer('HeroSubLoop');}
    }
    else if(validateCP('Female_3rdFloorPosthole'))
    {
        SetPlayerSpeed(55,110,330);
        SetJumpPunishment(101,0.02);
        SetTimer(1, false, 'OtherLoop');
        SetTimer(0.5, false, 'BackPawnCol');
    }
    else if(validateCP('Female_Tobigjump'))
    {
        SetPlayerSpeed();
        SetJumpPunishment();
    }
    else if(validateCP('Female_LostCam'))
    {
        SetPlayerSpeed();
        SetJumpPunishment(45, 3);
        SetTimer(1, false, 'SubLoop');
    }
    else if(validateCP('Female_FoundCam'))
    {
        SetPlayerSpeed(55,110,350);
        SetJumpPunishment(102, 0.02);
        if(GlobalEnemy !=None)
        {   Controller.Kill(GlobalEnemy);}
        SetTimer(1, false, 'OtherLoop');
        SetTimer(0.1, true, 'SubLoop');
        EPHud(Controller.Hud).TopMiddleStr ="";
    }
    else if(validateCP('Female_Jump'))
    {
        CB1 =false;
        SetPlayerSpeed(,,370);
        SetJumpPunishment();
    }
    // Revisit HL
    else if(validateCP('Revisit_Soldier1'))
    {
        SetPlayerSpeed(55,110,330);
        SetJumpPunishment(101,0.02);
        SetTimer(1, false, 'OtherLoop');
    }
    else if(validateCP('Revisit_Mezzanine'))
    {
        SetPlayerSpeed(55,110,370);
        SetJumpPunishment(101,0.02);
        SetTimer(1, false, 'OtherLoop');
        SetTimer(0.4, false, 'SubLoop');
    }
    else if(validateCP('Revisit_ToRH'))
    {
        if(GlobalEnemy !=None)
        {   Controller.Kill(GlobalEnemy);}
        SetPlayerSpeed();
        SetJumpPunishment();
    }
    else if(validateCP('Revisit_RH'))
    {
        SetJumpPunishment();
        SetPlayerSpeed();
        SetTimer(0.1, true, 'SubLoop');
        SetTimer(0.11, true, 'HeroSubLoop');
    }
    else if(validateCP('Revisit_FoundKey'))
    {
        SetJumpPunishment(101,0.02);
        SetPlayerSpeed(55,110,330);
        SetTimer(1,false,'OtherLoop');
        Controller.SetGameSpeed();
    }
    else if(validateCP('Revisit_To3rdfloor') || validateCP('Revisit_3rdFloor') || validateCP('Revisit_RoomCrack') || validateCP('Revisit_ToChapel') || validateCP('Revisit_PriestDead') || validateCP('Lab_EBlock'))
    {
        SetPlayerSpeed();
        SetJumpPunishment();
        Controller.SetGameSpeed(1.5);
    }
    else if(validateCP('Revisit_Soldier3'))
    {
        SetPlayerSpeed(55,110,350);
        SetJumpPunishment(101,0.02);
        Controller.SetGameSpeed();
        SetTimer(1,false,'OtherLoop');
    }
    // Lab HL
    else if(validateCP('Lab_Start'))
    {
        SetPlayerSpeed(55,110,330);
        SetJumpPunishment(101,0.02);
        SetTimer(0.1,true,'HeroSubLoop');
        InitAmpel(true);
    }
    else if(validateCP('Lab_Soldierdead') || validateCP('Lab_SpeachDone'))
    {
        SetPlayerSpeed();
        SetJumpPunishment();
        Controller.SetGameSpeed(3);
    }
    else if(validateCP('Lab_SwarmCafeteria'))
    {
        SetJumpPunishment(101,0.02);
        SetPlayerSpeed(,,350);
        SetTimer(1, false,'OtherLoop');
        Controller.SetGameSpeed();
    }
    else if(validateCP('Lab_ToBilly') || validateCP('Lab_BigRoom') || validateCP('Lab_BigRoomDone'))
    {  
        Controller.SetGrainBrightness();
        SetPlayerSpeed();
        SetTimer(0.3, false,'OtherLoop');
        if(CurrentCP=='Lab_BigRoomDone')
        {   
            SetJumpPunishment(51,1.5);
            Controller.SetGameSpeed();
            SetTimer(1, false,'SubLoop');
        }
        else
        {
            SetJumpPunishment();
            Controller.SetGameSpeed(1.5);
        }
    }
    else if(validateCP('Lab_BigTower'))
    {
        SetPlayerSpeed();
        SetJumpPunishment();
        SetTimer(RandRange(0.3,0.6), false, 'HeroSubLoop');
    }
    else if(validateCP('Lab_BigTowerStairs'))
    {
        Controller.SetGrainBrightness();
        SetPlayerSpeed();
        SetJumpPunishment();
        if(IsTimerActive('HeroSubLoop'))
        {   ClearTimer('HeroSubLoop');}
    }
    else if(validateCP('Lab_BigTowerDone'))
    {
        SetJumpPunishment();
        SetPlayerSpeed();
        SetTimer(1, false,'OtherLoop');
        SetTimer(0.2,true,'HeroSubLoop');
        SetTimer(0.2, false,'SubLoop');
    }
}

private Function HeroSubLoop()
{
    Local OLEnemyPawn P;

    // AdminHSL
    if(CurrentCP =='Admin_Gates')
    {
        InitBMSG("Welcome to\nExtreme Plus 3", SoundCue'EPlusAssets.Sound.Wush_Cue', 5, 0.5);
    }
    else if(CurrentCP =='Admin_Mezzanine')
    {
        if(LocomotionMode ==LM_Cinematic)
        {
            ClearTimer('HeroSubLoop');
            ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
            {
                if(P.Tag =='EPA')
                {   Controller.Kill(P);}
            }
        }
    }
    else if(CurrentCP =='Admin_WheelChair' && InRange(Vect(-6763.8232, 2858.2085, -1.8402), Location, 170))
    {
        ClearTimer('HeroSubLoop');
        Controller.SetGameSpeed(1);
    }
    // PrisonHSL
    else if(CurrentCP =='Prison_Start')
    {
        if(LocomotionMode ==LM_Cinematic)
        {
            
            Controller.SetGameSpeed(MaxInt);
        }
        else
        {
            Controller.SetGameSpeed();
        }
    }
    else if(CurrentCP =='Prison_ToPrisonFloor')
    {
        Controller.SetGrainBrightness(-1000);
    }
    else if(CurrentCP =='Prison_PrisonFloor_3rdFloor')
    {
        if(InRange(GlobalEnemy.Location, Vect(620.2593, 2215.1472, 910.4406), 150) && !CB1)
        {   CB1=true;}
        else if(CB1 && !CB2 && InRange(Vect(1651.2950, 2008.0258, 998.1500), Location, 100))
        {   
            CB2 =true;
            Controller.bCPActive=true;
            Controller.SendMSG("Unlocked next Checkpoint");
            // InitBMSG("Unlocked Checkpoint!", SoundCue'EPlusAssets.Sound.PopUp_Cue', 3, 0.3);
        }
    }
    else if(CurrentCP =='Prison_OldCells_PreStruggle' && LocomotionMode ==LM_Cinematic)
    {
        ClearTimer('HeroSubLoop');
        SetTimer(3.0, false, 'SubLoop');
    }
    // SewerHSL
    // Sewer pre Citern
    else if((CurrentCP =='Sewer_FlushWater' || CurrentCP =='Sewer_WaterFlushed') && !CB1 && InRange(Vect(1953.8452, 1855.2516, -351.9149), Location, 500))
    {   CB1 =true; ExposePosition(GlobalEnemy, 0.5);}    
    else if((CurrentCP =='Sewer_FlushWater' || CurrentCP =='Sewer_WaterFlushed') && !CB2 && LocomotionMode ==LM_Cinematic && InRange(Vect(-701.3400, 7715.3447, -351.8500), Location, 200))
    {
        CB2 =true;
        InitBMSG("Hold LeftMouse 3sec \n to gain 3x speed \n for 3sec (1x usage)", SoundCue'EPlusAssets.Sound.Message_Cue', 5, 0.2);
        StartBonus();
    }
    else if((CurrentCP =='Sewer_FlushWater' || CurrentCP =='Sewer_WaterFlushed') && !CBOther && LocomotionMode ==LM_Cinematic && InRange(Vect(1796.3777, 1696.1051, -351.7151), Location, 200))
    {
        CBOther =true;
    }
    else if((CurrentCP =='Sewer_FlushWater' || CurrentCP =='Sewer_WaterFlushed') && CBOther && LocomotionMode !=LM_cinematic && InRange(Vect(437.5744, 7114.3774, -395.1663), GlobalEnemy.Location, 200))
    {
        GlobalEnemy.SetLocation(Vect(229.3830, 8131.5786, -400.3631));
        CBOther =false;
    }
    // Sewer pre Citern Ende
    else if(CurrentCP =='Sewer_Citern2' && GetMaterialBelowFeet() =='Metal_Light')
    {
        SetJumpPunishment(90, 5);
        ET(GlobalEnemy).SetEnemySpeed(,,700)
        .SetEnemyAttackAndDoor(400);
        ClearTimer('HeroSubLoop');
    }
    // MaleESL
    else if(CurrentCP =='Male_Chase' && InRange(Vect(-5848.7500, -8646.9883, -451.8500), Location, 200))
    {
        SetJumpPunishment(90, 3);
        InitBMSG("Can jump again!", SoundCue'EPlusAssets.Sound.Message_Cue', 1.5, 0.2);
        ClearTimer('HeroSubLoop');
    }
    else if(CurrentCP =='Male_ChasePause')
    {
        SetJumpPunishment(24, Maxint);
    }
    else if(CurrentCP =='Male_Torture' )
    {
        if(GetTimerRate('HeroSubLoop') !=0.03)
        {   SetTimer(0.03, true,'HeroSubLoop');}
        if(Input.IsKeyPressed('LeftMouseButton'))
        {   Controller.CP("Male_TortureDone");}
    }
    else if(CurrentCP =='Male_Surgeon')
    {
        if(InRange(Vect(-3612.0938, -7798.5298, 998.1500), Location, 300) && LocomotionMode==LM_Pushing && !GlobalEnemy.ISA('OLEnemySurgeon'))
        {   Controller.SetGameSpeed(10);}
        else
        {   Controller.SetGameSpeed();}
    }
    else if(CurrentCP =='Male_Cafeteria' && InRange(Vect(-2063.3328, -11205.9082, -1.8827), Location, 200))
    {
        ClearTimer('HeroSubLoop');
        InitBMSG("Mind the time limit\nfor sprinklers!", SoundCue'EPlusAssets.Sound.Walrider_ChaseMusic_Start_Cue', 5, 0.1);
    }
    else if(CurrentCP =='Male_SprinklerOff' || CurrentCP =='Male_SprinklerOn')
    {
        if(GetRemainingTimeForTimer('KillSelf')%60 <10)
        { EPHud(Controller.Hud).TopMiddleStr =String(Int(GetRemainingTimeForTimer('KillSelf')/60))$".0"$Int(GetRemainingTimeForTimer('KillSelf')%60);}
        else
        {   EPHud(Controller.Hud).TopMiddleStr =string(Int(GetRemainingTimeForTimer('KillSelf')/60))$"."$Int(GetRemainingTimeForTimer('KillSelf')%60);}
        if(CurrentCP =='Male_SprinklerOn' && inRange(Vect(-768.9078, -10954.7422, -1.8500), Location, 200))
        {
            ClearTimer('KillSelf');
            EPHud(Controller.Hud).TopMiddleStr ="";
            SetJumpPunishment();
            SetPlayerSpeed();
            ClearTimer('HeroSubLoop');
        }
    }
    // Courtyard hsl
    // Female hsl
    else if(CurrentCP =='Female_KeyPickedup' && InRange(Vect(-2780.5552, 8823.6396, 178.1500), Location, 200))
    {
        ClearTimer('HeroSubLoop');
        bHobbling =true;
    }
    else if(CurrentCP =='Female_3rdFloor')
    {
        if(LocomotionMode ==LM_LedgeWalk)
        {
            Controller.bHasCamcorder =false;
            Controller.SetGrainBrightness(-1000);
            SetJumpPunishment();
        }
        else
        {
            Controller.bHasCamcorder =true;
            Controller.SetGrainBrightness();
            SetJumpPunishment(101,0.02);
        }
    }
    else if(CurrentCP =='Female_FoundCam')
    {
        if(IsTimerActive('PCH'))
        {
            if(SpecialMove==SMT_GrabLedgeFromGround || SpecialMove ==15)
            {   StartSpecialMove(SMT_HeroDecapitate);}
            EPHud(Controller.Hud).TopMiddleStr =String(Int(GetRemainingTimeForTimer('PCH')));
        }
        else
        {
            ClearTimer('HeroSubLoop');
            EPHud(Controller.Hud).TopMiddleStr ="";
        }
    }
    // Revisit HSL
    else if(CurrentCP =='Revisit_RH' && InRange(Vect(-3946.3059, 960.8404, 700.1655), Location, 100) && GlobalEnemy !=None)
    {   
        ClearTimer('HeroSubLoop');
        Controller.Kill(GlobalEnemy);
    }
    else if(CurrentCP =='Lab_Start' || CurrentCP =='Lab_PremierAirlock' || CurrentCP =='Lab_SwarmIntro' || CurrentCP =='Lab_SwarmIntro2')
    {
        if((LichtA.Tag =='Gelb' || LichtA.Tag =='Rot') && Controller.FXManager.CurrentUberPostEffect.GrainBrightness ==-1000)
        {
            Controller.SetGrainBrightness();
        }
        else if(LichtA.Tag =='EPA' && Controller.FXManager.CurrentUberPostEffect.GrainBrightness !=-1000)
        {
            Controller.SetGrainBrightness(-1000);
        }
        if(CurrentCP =='Lab_SwarmIntro2' && LocomotionMode ==LM_Cinematic)
        {   
            ClearTimer('HeroSubLoop'); 
            InitAmpel(false);
            Controller.SetGrainBrightness();
        }
    }
    else if(CurrentCP =='Lab_BigTower')
    {
        SetTimer(RandRange(0.3,0.6),false,'HeroSubLoop');
        if(Controller.FXManager.CurrentUberPostEffect.GrainBrightness ==-1000)
        {   Controller.SetGrainBrightness();}
        else
        {   Controller.SetGrainBrightness(-1000);}
    }
    else if(CurrentCP =='Lab_BigTowerDone' && InRange(Vect(-20598.6895, -1935.4657, -4101.8496), Location, 300))
    {
        ClearTimer('HeroSubLoop');
        if(EPGame(WorldInfo.Game).DifficultyMode ==EDM_Insane)
        {
            InitBMSG("Huge Respect!!!",SoundCue'EPlusAssets.Sound.PopUp_Cue',7,0.1);
        }
        else
        {   InitBMSG("GG, now on Insane.",SoundCue'EPlusAssets.Sound.PopUp_Cue',7,0.1);}
        Controller.Kill();
    }
}

// Other Functions/loops

private Function OtherLoop()
{
    Local OLDoor Door;
    Local OLBed Bed;
    if(CurrentCP =='Admin_SecurityRoom' || CurrentCP =='Prison_PrisonFloor_SecurityRoom1' || CurrentCP =='Prison_PrisonFloor02_SecurityRoom2' || CurrentCP =='Male_Chase' || CurrentCP =='Male_ChasePause' || CurrentCP =='Male_SprinklerOff' || CurrentCP =='Female_KeyPickedup' || CurrentCP =='Female_3rdFloor' || CurrentCP =='Female_FoundCam' || CurrentCP =='Revisit_Soldier1' || CurrentCP =='Revisit_Mezzanine')
    {
        ForEach AllActors(Class'OLDoor', Door)
        {
            Door.bDontBreak=true;
            Door.bAlwaysBreak=false;
        }
    }
    else if(CurrentCP == 'Admin_Basement')
    {
        ForEach AllActors(Class'OLDoor', Door)
        {
            if(InRange(Vect(-6338.5366, -742.3231, -651.8499), Door.Location, 100))
            {
                Door.breakDoor(self, false);
                continue;
            }
            else if(InRange(Vect(-8470.3408, 909.9427, -551.8500), Door.Location, 100))
            {
                Door.bDontBreak =false;
                Door.bAlwaysBreak=true;
                continue;
            }
            Door.bDontBreak=true;
            Door.bAlwaysBreak=false;
            Door.bAIAlwaysCloses=true;
        }
    }
    else if(CurrentCP =='Prison_IsolationCells02_PostSoldier' || CurrentCP =='Prison_OldCells_PreStruggle' || CurrentCP =='Prison_Showers_Exit')
    {
        ForEach AllActors(Class'OLDoor', Door)
        {
            if((InRange(Vect(3279.7598, 1815.9895, 998.1500), Door.Location, 100) || InRange(Vect(2812.6125, 390.4645, 1000.0302), Door.Location, 100)) && Door.DoorBreakState !=DBS_Broken)
            {   Door.breakDoor(self, false); continue;}
        }
    }
    else if(CurrentCP =='Prison_OldCells_PreStruggle2')
    {
        ForEach AllActors(Class'OLDoor', Door)
        {
            if((InRange(Vect(3279.7598, 1815.9895, 998.1500), Door.Location, 100) || InRange(Vect(2812.6125, 390.4645, 1000.0302), Door.Location, 100)) && Door.DoorBreakState !=DBS_Broken)
            {   Door.breakDoor(self, false); continue;}
            Door.bAlwaysBreak=true;
            Door.bDontBreak=true;
        }
    }
    else if(CurrentCP =='Sewer_FlushWater')
    {
        ForEach AllActors(Class'OLDoor', Door)
        {
            if(InRange(Vect(1953.8452, 1855.2516, -351.9149), Door.Location, 100))
            {   Door.breakDoor(self,false); break;}
        }
    }
    else if(CurrentCP =='Male_TortureDone')
    {
        ForEach AllActors(Class'OLDoor', Door)
        {
            if(InRange(Vect(-1873.8527, -9143.5615, 998.1503), Door.Location, 150))
            {   Door.BreakDoor(self, false);}
            else if(InRange(Vect(-1239.9124, -8447.0996, 998.1500), Door.Location, 300))
            {
                Door.balwaysbreak =true;
                Door.bdontbreak =false;
            }
            else
            {  
                Door.bAlwaysBreak =false;
                Door.bDontBreak =true;
            }
        }
    }
    // Enemy always breaks
    else if(CurrentCP =='Male_Surgeon' || CurrentCP =='Female_3rdFloorPosthole' || CurrentCP =='Revisit_Soldier3')
    {
        ForEach AllActors(Class'OLDoor', Door)
        {
            Door.bAlwaysBreak =true;
            Door.bDontBreak =false;
        }
    }
    else if(CurrentCP =='Male_GetTheKey')
    {
        ForEach AllActors(Class'OLDoor', Door)
        {
            Door.bAlwaysBreak =true;
            Door.bDontBreak =false;
        }
        ForEach AllActors(Class'OLBed', Bed)
        {
            if(InRange(Vect(-627.0923, -10548.7852, 998.1503), Bed.Location, 2000))
            {   Bed.Destroy();}
        }
    }
    else if(CurrentCP =='Female_2ndFloor' || CurrentCP =='Female_2ndfloorChute')
    {
        ForEach AllActors(Class'OLDoor', Door)
        {
            if(InRange(Vect(-756.7597, 7725.2280, 548.8126), Door.Location, 100) || InRange(Vect(-5247.6323, 11950.6445, 548.8126), Door.Location, 100))
            {
                Door.BreakDoor(self, false);
                Continue;
            }
            Door.bAlwaysBreak =false;
            Door.bDontBreak =true;
        }
    }
    else if(CurrentCP =='Revisit_FoundKey')
    {
        ForEach AllActors(Class'OLDoor', Door)
        {
            if(InRange(Vect(-5709.6689, 15.1624, 365.1656), Door.Location, 100))
            {
                Door.BreakDoor(self,false);
                continue;
            }
            Door.bAIAlwaysCloses =false;
            Door.bDontBreak =true;
            Door.bAlwaysBreak =false;
        }
    }
    else if(CurrentCP =='Lab_SwarmCafeteria')
    {
        ForEach AllActors(Class'OLDoor', Door)
        {   Door.bCantClose =true;}
    }
    else if(CurrentCP =='Lab_ToBilly' || CurrentCP =='Lab_BigRoom' || CurrentCP =='Lab_BigRoomDone')
    {
        ForEach AllActors(Class'OLDoor', Door)
        {
            if(InRange(Vect(-24058.1758, -4356.7432, -4301.1733), Door.Location, 150) || InRange(Vect(-23348.0801, -6407.1284, -4301.1733), Door.Location, 150))
            {   Door.BreakDoor(self,false);}
        }
    }
    else if(CurrentCP =='Lab_BigTowerDone')
    {
        ForEach AllActors(Class'OLDoor',Door)
        {
            if(InRange(Vect(-20600.0840, -723.7616, -4101.1729), Door.Location, 100))
            {   Continue;}
            Door.BreakDoor(self,false);
        }
    }
}

 Function CPController()
{
    // AdminCPC
    if(CurrentCP =='Admin_Basement')
    {
        TP(-8026.3477, -102.6420, -552.2194,0, 32276, 0);
    }
    // go one back.
    else if(CurrentCP == 'Admin_Electricity' 
    || CurrentCP =='Prison_IsolationCells01_Mid' 
    || (CurrentCP =='Prison_PrisonFloor_SecurityRoom1' && !Controller.bCPActive) 
    || CurrentCP =='Prison_PrisonFloor02_SecurityRoom2'
    || CurrentCP =='Sewer_WaterFlushed'
    || CurrentCP =='Male_SprinklerOn'
    || CurrentCP =='Female_ChuteActivated'
    || CurrentCP =='Female_3rdFloorPosthole'
    || CurrentCP =='Revisit_To3rdfloor'
    || CurrentCP =='Lab_BigTower')
    {
        CPBack(CurrentCP);
    }
    // PrisonCPC
    else if(CurrentCP =='Prison_PrisonFloor_3rdFloor')
    {
        Controller.bCPActive=false;
    }
    else if(CurrentCP =='Prison_Showers_2ndFloor')
    {
        TP(5596.3555, 2014.1335, 998.3906, 0, -625, 0);
    }
    // male cpc
        else if(CurrentCP =='Male_GetTheKey2' || CurrentCP =='Male_Elevator')
    {   ContextualCP('Male_GetTheKey');}
    // Courtyard CPC
    else if(CurrentCP =='Courtyard_Soldier2')
    {   TP(-4088.9114, 3072.2415, 28.1500,0, -785, 0);}
    // Female CPC
    else if(CurrentCP =='Female_3rdFloorHole')
    {   TP(-3872.3940, 10539.4268, 998.1505,0, -32084,0);}
    else if(CurrentCP =='Female_FoundCam')
    {   TP(-5748.1733, 11661.5352, -1.8495,0, -17215, 0);}
    // lab cpc
    else if(CurrentCP =='Lab_PremierAirlock' || CurrentCP =='Lab_SwarmIntro' || CurrentCP =='Lab_SwarmIntro2')
    {   ContextualCP('Lab_Start');}
    else if(CurrentCP =='Lab_SwarmCafeteria')
    {   TP(-17231.1387, -1123.8467, -4651.8496,0, 15332, 0);}
}

private function ContextualCP(Name CP){
    local String CPS;

    CPS =String(CP);
    if(Respawning){
        if(EPGame(WorldInfo.Game).DifficultyMode !=EDM_Insane){
            Respawning =false;
            Controller.StartNewGameAtCheckPoint(CPS, true);
        }
    }
    else{
        Controller.CP(CPS);
    }
}

function CPBack(Name CP){
    ContextualCP(Class'CPList'.static.GetPreviousCP(CP));
}

/********** Event Chains **********/
// LocationSwap
exec Function LocationSwap()
{
    Local Vector C, E;
    Local OLEnemyPawn Enemy;

    C =Location;
    ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', Enemy)
    {
        E =Enemy.Location;
        break;
    }

    if(E ==Vect(0,0,0)){
        return;
    }
    SetLocation(E);
    ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', Enemy){
        Enemy.SetCollision(false, false,false);
        Enemy.SetLocation(C);
        SetTimer(0.2, false, 'BackPawnCol');
    }
}
Function BackPawnCol()
{
    Local OLEnemyPawn P;
    ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
    {
        P.SetCollision(true,true,true);
    }
}

// Bonus
event StartBonus()
{
    if(!IsTimerActive('StartBonus'))
    {   SetTimer(0.03, true, 'StartBonus');}
    if(Input.ISKeyPressed('LeftMouseButton'))
    {
        if(!IsTimerActive('NoBonus'))
        {
            SetTimer(1, false, 'NoBonus');
        }
    }
    else
    {
        ClearTimer('NoBonus');
    }
}
Function NoBonus()
{
    ClearTimer('StartBonus');
    PlaySound(SoundCue'EPlusAssets.Sound.Wush_Cue');
    SetPlayerSpeed(165,330,990);
    SetTimer(3, false, 'BackSpeed');
}
Function BackSpeed()
{
    SetPlayerSpeed(55,110,330);
}

// AmpelFunktion
Event InitAmpel(bool Enable =true)
{
    if(Enable)
    {
        LichtA =Spawn(Class'EPPointlight',,'EPA');
        LichtA.SetBrightness(0.7);
        LichtA.SetColor(0,255,0,200);
        LichtA.SetRadius(1024);
        LichtA.SetCastDynamicShadows(true);        
        SetTimer(0.001, true, 'MoveAmpel');
        GruenZuGelb();
    }
    else
    {
        ClearTimer('MoveAmpel');
        ClearTimer('GruenZuGelb');
        ClearTimer('GelbZuRot');
        ClearTimer('StartRot');
        ClearTimer('AmpelRot');
        LichtA.Destroy();
    }
}
Function GruenZuGelb()
{
    LichtA.SetColor(0,255,0,200);
    SetTimer(RandRange(2,6), false, 'GelbZuRot');
}
Function GelbZuRot()
{
    LichtA.SetColor(241, 245, 39, 0.8);
    LichtA.Tag ='Gelb';
    SetTimer(RandRange(0.35,1.2), false, 'StartRot');
}
function StartRot()
{   SetTimer(0.1, true, 'AmpelRot');}
Function AmpelRot()
{
    if(LichtA.Tag !='Rot')
    {   
        LichtA.SetColor(255,0,0,255); 
        LichtA.Tag ='Rot'; 
        SetTimer(RandRange(2.2,4.5), false, 'PCH');
    }
    if(IsTimerActive('PCH'))
    {
        if(VSize(Velocity) >0)
        {
            LichtA.Destroy();
            StartSpecialMove(SMT_HeroDecapitate);
            return;
        }
        return;
    }
    ClearTimer('AmpelRot');
    LichtA.Tag ='EPA';
    GruenZuGelb();
}
Function MoveAmpel()
{
    Local Rotator Rot;
    Local Vector C;
    Controller.GetPlayerViewPoint(C,Rot);
    LichtA.SetLocation(C);
}
// ExposePosition
Event ExposePosition(OLEnemyPawn P, float Length =2, bool Enable =true)
{   
    if(!IsTimerActive('SeeLoop'))
    {   
        bSee =Enable;
        ExPoseEnemy =P;    
        UnExpose =Length;
        SeeLoop();
        SetTimer(1, true, 'SeeLoop'); 
    }
}
Function SeeLoop()
{
    Class'EnemyUtils'.static.init(ExPoseEnemy)
    .nohide(bSee);
    if(!IsTimerActive('BackSC'))
    {
        SetTimer(UnExpose, false, 'BackSC');
    }
}
Function BackSC()
{
    ClearTimer('SeeLoop');
    Class'EnemyUtils'.static.init(ExPoseEnemy)
    .nohide(!bSee);
    ExPoseEnemy =None;
}

// Message Chain
Event InitBMSG(string Text, SoundCue InSoundCue, float Duration =5, float Delay =0.0)
{
    PlaySound(InSoundCue);
    Message =Text;
    MessageDisplayDuration =Duration;
    SetTimer(Delay, false, 'DDM');
}
Function DDM()
{
    Controller.BigMsg(Message, MessageDisplayDuration);
}

/********** BasisFunktionen */

private final function EnemyUtils ET(optional OLEnemyPawn P){
    if (P !=none){
        return class'EnemyUtils'.static.init(P);
    }
    return class'EnemyUtils'.static.init();
}

final function bool InRange(Vector A, Vector B, float Range)
{
    return VSize(A-B) <=Range;
}

final function bool IsPointInCone(Vector P, Vector V, Rotator ConeRot, float ConeHalfAngle)
{
    local Vector VP, ConeAxis, A;
    local float CosAngle, CosHalfAngle;

    // Berechne den Vektor vom Kegel-Scheitelpunkt zum Punkt P
    VP = P - V;

    // Falls der Punkt genau am Scheitelpunkt liegt, ist er im Kegel
    if (IsZero(VP))
    {
        return true;
    }

    // Normale Kegelachse aus Rotator extrahieren
    GetAxes(ConeRot, ConeAxis, A, A); // X-Achse ist die Vorwärtsrichtung

    // Berechne den Kosinus des Winkels zwischen VP und der Kegelachse
    CosAngle = Normal(VP) dot ConeAxis;

    // Berechne den Kosinus des halben Kegelöffnungswinkels
    CosHalfAngle = cos(ConeHalfAngle);

    // Ist der Punkt innerhalb des Kegels?
    return CosAngle >= CosHalfAngle;
}

Function PCH()
{
    // Dummy function
}

Function SetPlayerSpeed(Float Crouch=75, Float Walk=200, Float Run=450, Float WaterWalk=100, Float WaterRun=200, Float HobbleWalk=140, Float HobbleRun =250, Float Limp=900)
{
    CrouchedSpeed=Crouch; NormalWalkSpeed=Walk; NormalRunSpeed=Run;
    WaterWalkSpeed=WaterWalk; WaterRunSpeed=WaterRun;
    LimpingWalkSpeed=Limp; HobblingWalkSpeed=HobbleWalk; HobblingRunSpeed=HobbleRun;
}

Function PlayerAnimRate(Float Rate=1) 
{
    Mesh.GlobalAnimRateScale=Rate;
}

Function JumpAbillity(float Penalty =1, float PenaltyModifier =0.25, float FwdWalk =450, float FwdRun =650, float clearWalk =200, float ClearRun =300, float DamageSpeed =1250, float Exp =1.5, float DeathSpeed =1500)
{
    LandingPenaltyDuration =Penalty;
    LandingSpeedModifier=PenaltyModifier;
    ForwardSpeedForJumpWalking=FwdWalk;
    ForwardSpeedForJumpRunning=FwdRun;
    JumpClearanceWalking=clearWalk;
    JumpClearanceRunning=ClearRun;
    FallSpeedForDamage=DamageSpeed;
    FallSpeedForDeath=DeathSpeed;
    FallDamageExponent=Exp;    
}

Function SetJumpPunishment(float Percentage =0, optional float HealDelay)
{
    if(Percentage ==0)
    {
        Healing();
        Controller.UpdateJumps();
        ClearTimer('PunishJump');
    }
    else
    {
        Healing(MaxInt, HealDelay);
        PDamage =Percentage;
        SetTimer(0.15, true, 'PunishJump');
        Controller.UpdateJumps(Percentage, HealDelay);
    }
}

Function PunishJump()
{
    if(bJumping)
    {
        DMGS(PDamage);
        bJumping =false;
    }
}

Function Healing(float Rate =10, float Delay =10)
{
    HealthRegenRate=Rate;
    HealthRegenDelay =Delay;
}

Function HeroStatics()
{
    JumpAbillity();
    SpeedPenaltyBackwards=0.35;
    SpeedPenaltyStrafe=0.2;
    LandingPenaltyDuration=1;
    LandingSpeedModifier=0.25;
    ElectrifiedJumpDelay=0.25;
    ExternalImpulseDecelCoeff=0.97;
    ExternalImpulseMinVel=60;
    ExternalImpulseMaxVel=1500;
    ExternalImpulseMaxVelCrouched=750;
    BatteryDuration =60;
    NVLightZoomedInInnerAngle=2;
    NVLightZoomedInOuterAngle=5;
    NVLightZoomedInRadius=1500;
    NVLightZoomedInBrightness=0.025;
    if (!Controller.bFB){
        DarkLightBrightnessDefault=0.01;
        DarkLightRadiusDefault=100;
        DarkLightBrightnessNoCamcorder=0.03;
        DarkLightRadiusNoCamcorder=175;
        DarkLightBrightnessBothHandsNeeded=0.03;
        DarkLightRadiusBothHandsNeeded=125;
        DarkLightBrightnessAttacked=0.025;
        DarkLightRadiusAttacked=140;
        DarkLightBrightnessParrying=0.015;
        DarkLightRadiusParrying=140;
    }
    NVGlitchTimeThreshold=25;
    NVGlitchMaxDelayStart=8;
    NVGlitchMaxDelayEnd=5;
    NVGlitchMinDuration=0.5;
    NVGlitchMaxDuration=3;
    NVGlitchMaxLevel=0.5;
    HobbleApproachRate=0.05;
    ElectricEffectPeriod=0.4;
    ElectricEffectBase=0.4;
    ElectricEffectMode=2;
    ElectricHurtSoundInterval=0.8;
    DeathScreenDuration=0.02;
    HeatDamageDist=150;
    HeatDamageInterval=0.25;
    HeatDamagePerSec=500;
    HeatMaxBlurDist=75;
    HeatMinBlurDist=250;
    HeatMinBlurAmount=0.8;
    HeatBlurApproachCoeffIn=0.99;
    HeatBlurApproachCoeffOut=0.5;
    MinCosAngleForPickup=0.98;
    PickupInteractRadius=30;
    JumpForwardFromLedgeWalkXYSpeed=400;
    JumpForwardFromLedgeWalkZSpeed=350;
    DropFromLedgeWalkXYSpeed=150;
    DropFromLedgeWalkZSpeed=300;
    LookBackCamRotOffset=155;
    LookBackCamBackOffset=60;
    LookBackCamSideOffset=20;
    LeanSpeedThreshold=25;
    WalkingLoudness=0.3;
    CrouchLoudness=0.1;
    RunningLoudness=10.0;
    WalkingWaterLoudness=0.3;
    CrouchWaterLoudness=0.1;
    HobblingWalkLoudness=0.3;
    HobblingRunLoudness=10.0;
    LandingBigLoudness=10;
    LandingSmallLoudness=0.3;
    LandingBigWaterLoudness=10;
    LandingSmallWaterLoudness=10;
    DoorOpenInstantLoudness=10;
    DoorOpenPartialLoudness=10;
    DoorCloseFastLoudness=10;
    DoorEnterLockerLoudness=0.2;
    DoorExitLockerLoudness=0.2;
    DoorRunThroughLoudness=10;
    MovingNoiseStartTime=0.3;
    MovingNoiseClearTime=1.0;
    Controller.DefaultNumBatteries=0;
    Controller.MaxNumBatteries=1;
    Controller.AIChaseMusicTimeDelay=MaxInt;
    Controller.FirstSoldierFindableCheckpoint='Admin_Gates';
    Controller.FirstSurgeonFindableCheckpoint='Male_TortureDone';
    if(Controller.NumBatteries > 1)
    {
        Controller.NumBatteries = 0;
    }    
}

exec Function KillSelf() {
    if (LocomotionMode ==LM_Cinematic){
        if (class'CPList'.static.IsCP(CurrentCP)){
            Controller.cp(string(CurrentCP));
        }
        else{
            controller.cp(string(OLGame(WorldInfo.game).CurrentCheckPointName));
        }
        return;
    }

    if(DeathScreenDuration >7){
        DeathScreenDuration =0;
    }
    if(LocomotionMode ==LM_Locker ||  LocomotionMode ==LM_Bed)
    {
        PreciseHealth =0;
    }
    else
    {
        DMGS(101);
    }
}

Exec Function DMGS(Float Amount)
{
    TakeDamage(Amount, none, Location, Vect(0,0,0), none);
}

exec Function TP(Float X, Float Y, Float Z, Float R1, Float R2, Float R3){
    Local Vector C;
    Local Rotator R;

    C.X =X;
    C.Y =Y;
    C.Z =Z;
    R.Pitch =R1;
    R.Yaw=R2;
    R.Roll=R3;
    SetLocation(C);
    SetRotation(R);    
}

Exec Function Cords(bool View =false)
{
    Local Vector C;
    Local Rotator Rot;

    if(View)
    {
        Controller.GetPlayerViewPoint(C,Rot);
        Controller.CopyToClipBoard("View Vect(" $C.X $"," @C.Y $"," @C.Z $") || Rot(" $Rot.Pitch $"," @Rot.Yaw $"," @Rot.Roll $")");
    }
    else
    {
        Controller.CopyToClipBoard("Vect(" $Location.X $"," @Location.Y $"," @Location.Z $")\nRot(" $Rotation.Pitch $"," @Rotation.Yaw $"," @Rotation.Roll $")");
    }
}

function FullBright(float Bright, float Radius){
    if(Controller.bFb)
    {
        DarkLightBrightnessDefault=Bright;
        DarkLightRadiusDefault=Radius;
        DarkLightBrightnessNoCamcorder=Bright;
        DarkLightRadiusNoCamcorder=Radius;
        DarkLightBrightnessBothHandsNeeded=Bright;
        DarkLightRadiusBothHandsNeeded=Radius;
        DarkLightBrightnessAttacked=Bright;
        DarkLightRadiusAttacked=Radius;
        DarkLightBrightnessParrying=Bright;
        DarkLightRadiusParrying=Radius;    
        bOverrideDarkLight =false;
        DarkLightOverrideBrightness =Bright;
        DarkLightOverrideRadius =Radius;
    }
    else
    {
        DarkLightBrightnessDefault=0.01;
        DarkLightRadiusDefault=100.0;
        DarkLightBrightnessNoCamcorder=0.03;
        DarkLightRadiusNoCamcorder=175.0;
        DarkLightBrightnessBothHandsNeeded=0.03;
        DarkLightRadiusBothHandsNeeded=125.0;
        DarkLightBrightnessAttacked=0.025;
        DarkLightRadiusAttacked=140.0;
        DarkLightBrightnessParrying=0.015;
        DarkLightRadiusParrying=140.0;
    }
}

Event RespawnHero()
{
    Respawning =true;
    Super.RespawnHero();
    if(Controller.bFreeCamOn)
    {
        Controller.ToggleFreeCam();
    }
    if(EPHud(Controller.Hud).ToggleHUD)
    {
        Controller.ToggleConsole(false);
    }
    CPController();
}

Function bool ValidateCP(name CP)
{
    if(CurrentCP ==CP && CurrentCP !=LastCP){
        LastCP =CurrentCP;
        return true;
    }
    return false;
}

Function GetCP()
{
    Local Name CP;
    CP =EPGame(Worldinfo.Game).CurrentCheckPointName;
    if(CP!=CurrentCP)
    {
        CurrentCP =CP;
    }
}

Event Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);
    getCP();
}

DefaultProperties
{
    LastCP ='Ungueltig'
}