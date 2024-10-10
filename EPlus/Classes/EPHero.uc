class EPHero extends OLHero;

enum EnemyVisionType
{
    EVT_Normal,
    EVT_EPDefault,
    EVT_Trippled,
    EVT_EPEule,
    EVT_EPAlt
};

var EPController Controller;
var EPInput Input;
Var EPPointLight Licht, LichtA;
Var OLEnemyPawn GlobalEnemy, GlobalEnemyA, ExPoseEnemy;
Var int I;
Var bool CB1, CB2, CBOther, bSee;
Var float MessageDisplayDuration, PDamage, UnExpose;
Var string Message;
Var Name LastCP, CurrentCP;

Function PossessedBy(Controller C, Bool bVehicleTransition) 
{
    Super.PossessedBy(C, bVehicleTransition);
    Controller = EPController(C);
    Input = EPInput(Controller.Playerinput);
}

Event PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(0.017, false, 'CPController');
    SetTimer(0.02, false, 'HeroStatics');
    SetTimer(0.09, true, 'EnemyLoop');
    SetTimer(0.125, true, 'HeroLoop');
}

/**********Enemy Functions**********/
Function EnemyLoop()
{
    Local OLEnemyPawn P;
    Local OLEnemyNanoCloud Walrider;
    Local OLEnemySoldier Soldier;
    Local OLBot Bot;

    // AdminEL
    if(CurrentCP =='Admin_Explosion' && !CB1)
    {
        CB1 =true;
        Walrider =Spawn(Class'OLEnemyNanoCloud', ,'EPA',Vect(-7128.2173, -3394.9155, 548.1500),,,true);
        Walrider.SetCollision(false,false,false);
        SetEnemyAttackAndDoor(Walrider, 300);
        SetStaticEnemyValues(Walrider);
        Walrider.Modifiers.bShouldAttack=true;
        Bot =Spawn(Class'OLBot');
        Bot.Possess(Walrider,false);
        Bot.SightComponent.bAlwaysSeeTarget=true;
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
                SetEnemySpeed(P, 2000, 2000, 2000);
                P.SetHidden(true);
                Soldier =Spawn(Class'OLEnemySoldier', ,'EPA',Vect(-8822.4912, 643.4636, 548.1499),,,true);
                SetStaticEnemyValues(Soldier);
                SetEnemyAttackAndDoor(Soldier, 1000);
                SetEnemySpeed(Soldier, 0, 0, 280);
                SetEnemyVisionAndHearing(Soldier, EVT_EPDefault);
                SetEnemyInvestigation(Soldier);
                Soldier.Modifiers.bShouldAttack=true;
                Soldier.Modifiers.bUseForMusic=false;
                Bot =Spawn(Class'OLBot');
                Bot.Possess(Soldier,false);
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
                SetStaticEnemyValues(Soldier);
                SetEnemySpeed(Soldier,190,700,700);
                SetEnemyAttackAndDoor(Soldier,,,,,2.0);
                ExposePosition(Soldier, 5);
                SetEnemyVisionAndHearing(Soldier, EVT_EPEule, 3000);
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
                SetStaticEnemyValues(P);
                SetEnemyInvestigation(P, 2, 200.0, 600.0, 60.0, 1200.0, 10.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 5.0, 0.0, false, false, true);
                SetEnemyAttackAndDoor(P, 1000.0, 200.0, 1.0, 15, 0.01, 101, 101, 101, 101, 0, 50.0);
                SetEnemyVisionAndHearing(P, EVT_EPEule, 3000);
                SetEnemySpeed(P, 270, 800, 900);
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
            GlobalEnemyA =Spawn(Class'OLEnemyGenericPatient',,'EPA', Vect(4695.7627, 3855.5132, 648.1500), Rot(0, -32142, 0),,true);
            SetStaticEnemyValues(GlobalEnemyA);
            SetEnemyAttackAndDoor(GlobalEnemyA,,,,,2.0);
            SetEnemySpeed(GlobalEnemyA,500,500,500);
            SetEnemyVisionAndHearing(GlobalEnemyA, EVT_Normal);
            GlobalEnemyA.BehaviorTree=OLBTBehaviorTree'Prison_01-LD.02_AI_Behaviors.Generic_FullLoop_BT';
            GlobalEnemyA.Modifiers.bUseForMusic=false;
            GlobalEnemyA.Modifiers.bShouldAttack=true;
            GlobalEnemyA.Mesh.SetSkeletalMesh(SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_19');
            Bot =Spawn(Class'OLBot');
            Bot.Possess(GlobalEnemyA,false);            

            GlobalEnemy=Spawn(Class'OLEnemyGenericPatient',,'EPB', Vect(4704.3364, 3061.9988, 648.1500), Rot(0, -22954, 0),,true);
            SetStaticEnemyValues(GlobalEnemy);
            SetEnemyAttackAndDoor(GlobalEnemy,500);
            SetEnemySpeed(GlobalEnemy,800,800,800);
            SetEnemyVisionAndHearing(GlobalEnemy, EVT_Normal);
            GlobalEnemy.BehaviorTree=OLBTBehaviorTree'Prison_01-LD.02_AI_Behaviors.Generic_FullLoop_BT';
            GlobalEnemy.Modifiers.bUseForMusic=false;
            GlobalEnemy.Modifiers.bShouldAttack=true;
            GlobalEnemy.Modifiers.WeaponToUse =Weapon_Knife;
            GlobalEnemy.ApplyModifiers(GlobalEnemy.Modifiers);
            GlobalEnemy.Mesh.SetSkeletalMesh(SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_19');            
            Bot =Spawn(Class'OLBot');
            Bot.Possess(GlobalEnemy,false);
        }
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done' && P.Tag !='EPA' && P.Tag !='EPB')
            {
                P.Tag ='Done';
                SetStaticEnemyValues(P);
                SetEnemyVisionAndHearing(P, EVT_Normal);
                SetEnemyAttackAndDoor(P, 1000);
                SetEnemySpeed(P, 120, 900, 750);
                P.BehaviorTree =OLBTBehaviorTree'Prison_01-LD.02_AI_Behaviors.Generic_FullLoop_BT';
                P.Modifiers.bUseForMusic=false;
                P.Modifiers.bShouldAttack=true;
                P.Modifiers.WeaponToUse =Weapon_Knife;
                P.ApplyModifiers(P.Modifiers);                
            }
        }
    }
    else if(CurrentCP == 'Prison_IsolationCells01_Mid')
    {
        EnemyFastDoor(GlobalEnemy, 3.0);
    }
    else if(CurrentCP =='Prison_PrisonFloor_3rdFloor')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done')
            {
                if(P.ISA('OLEnemyGenericPatient_J'))
                {
                    SetStaticEnemyValues(P);
                    SetEnemySpeed(P,120,120,120);
                    SetEnemyVisionAndHearing(P, EVT_EPEule);
                    SetEnemyAttackAndDoor(P, 650);
                    P.Tag ='Done';
                }
                else
                {
                    SetStaticEnemyValues(P);
                    SetEnemyVisionAndHearing(P, EVT_EPEule, 3000);
                    SetEnemyAttackAndDoor(P, 800);
                    SetEnemySpeed(P,199,600,600);
                    SetEnemyInvestigation(P, 16, 400.0, 800.0, 60.0, 2000.0, 1.0, 10.0, 10.0, 10.0, 10.0, 1.0, 0.0, 10.0, 0.0, true, true, true);
                    P.Tag ='Done';
                    GlobalEnemy =P;
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
            SetStaticEnemyValues(P);
            SetEnemyAttackAndDoor(P);
            SetEnemySpeed(P, 550,550,550);
            P.BehaviorTree=OLBTBehaviorTree'Prison_01-LD.02_AI_Behaviors.Generic_FullLoop_BT';
            P.Bot.SightComponent.bAlwaysSeeTarget=true;
            EnemyFastDoor(P, 2.0);
        }
    }
    else if(CurrentCP =='Prison_Showers_2ndFloor')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done' && P.ISA('OLEnemyGenericPatient_G'))
            {
                if(!InRange(Vect(5033.6851, 2053.8438, 998.2878), P.Location, 700))
                    {   Kill(P);}
                SetStaticEnemyValues(P);
                SetEnemySpeed(P, 300, 345, 750);
                SetEnemyAttackAndDoor(P, 200.0, 200.0, 0.0,, 1.5);
                SetEnemyVisionAndHearing(P, EVT_EPEule);
                P.Bot.SightComponent.bAlwaysSeeTarget=true;
                P.BehaviorTree=OLBTBehaviorTree'Prison_01-LD.02_AI_Behaviors.Generic_FullLoop_BT';
                P.tag ='Done';
            }
            if(Specialmove ==SMT_ClimbUpLedge && P.Tag =='Done')
            {
                SetPlayerSpeed(50,100,150);
                P.SetLocation(Vect(5965.7251, -70.7976, 998.4135));
                P.SetRotation(Rot(0, 16524, 0));
                SetEnemyAttackAndDoor(P, 2000);
            }
        }
    }
    else if(CurrentCP =='Prison_PrisonFloor02_SecurityRoom2')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemySoldier', Soldier)
        {
            SetStaticEnemyValues(Soldier);
            SetEnemyAttackAndDoor(Soldier);
            SetEnemySpeed(Soldier, 1000,1000,1000);
            NoHide(Soldier);
            EnemyFastDoor(Soldier, 3.75);
        }
    }
    else if(CurrentCP =='Prison_IsolationCells02_Soldier')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemySoldier', Soldier)
        {
            if(Soldier.Tag !='Done')
            {
                SetStaticEnemyValues(Soldier);
                SetEnemyAttackAndDoor(Soldier, 800,,,,,,,,,,1.0);
                SetEnemySpeed(Soldier, 530,680,900, 220,510,565);
                SetEnemyVisionAndHearing(Soldier, EVT_EPEule, 1000);
                SetEnemyInvestigation(Soldier);
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
                SetStaticEnemyValues(P);
                SetEnemyAttackAndDoor(P);
                SetEnemyVisionAndHearing(P, EVT_Normal);
                SetEnemySpeed(P, 705,705,705);
                P.Modifiers.bShouldAttack=true;
                P.BehaviorTree=OLBTBehaviorTree'Prison_01-LD.02_AI_Behaviors.Generic_FullLoop_BT';
                P.SetOnlyOwnerSee(true);
                P.Tag ='Done';
                GlobalEnemyA =P;
            }
        }
    }
    else if(CurrentCP =='Prison_OldCells_PreStruggle' && GlobalEnemy !=None)
    {
        EnemyFastDoor(GlobalEnemy, 2.5);
        NoHide(GlobalEnemy);
    }
    else if(CurrentCP =='Prison_OldCells_PreStruggle2')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done')
            {
                SetStaticEnemyValues(P);
                SetEnemyInvestigation(P);
                SetEnemyAttackAndDoor(P);
                SetEnemySpeed(P, 800,800,800);
                SetEnemyVisionAndHearing(P, EVT_EPAlt);
                P.Modifiers.WeaponToUse =Weapon_Knife;
                P.ApplyModifiers(P.Modifiers);
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
                Kill(Walrider);
            }
        }
        NoHide(GlobalEnemy);
    }
    else if(CurrentCP =='Sewer_FlushWater' || CurrentCP =='Sewer_WaterFlushed')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemySoldier', Soldier)
        {
            if(Soldier.Tag !='Done')
            {
                SetStaticEnemyValues(Soldier);
                SetEnemySpeed(Soldier, 325, 900, 900, 200);
                SetEnemyVisionAndHearing(Soldier, EVT_EPEule);
                SetEnemyAttackAndDoor(Soldier, 900, 700);
                SetEnemyInvestigation(Soldier, 16, 700.0, 1000.0, 60.0, 2000.0, 1.0, 10.0, 10.0, 10.0, 10.0, 1.0, 1.0, 5.0,,false,false,true);
                Soldier.Tag ='done';
                GlobalEnemy =Soldier;
            }
        }
    }
    else if (CurrentCP =='Sewer_Citern2')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemySoldier', Soldier)
        {
            if(soldier.Tag !='done')
            {
                SetStaticEnemyValues(Soldier);
                SetEnemySpeed(Soldier, 275, 500, 450);
                SetEnemyVisionAndHearing(Soldier, EVT_EPAlt, 1000);
                SetEnemyAttackAndDoor(Soldier, 200);
                SetEnemyInvestigation(Soldier, 4, 200.0, 600.0, 60.0, 1200.0, 10.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 3.0, 0.0, false, false, True);
                Soldier.Tag ='done';
                GlobalEnemy =Soldier;
            }
        }
    }
    else if(CurrentCP =='Sewer_PostCitern')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            If(P.Tag !='mate' && P.IsA('OLEnemyGenericPatient_A'))
            {
                SetStaticEnemyValues(P);
                SetEnemyVisionAndHearing(P, EVT_EPAlt);
                SetEnemyAttackAndDoor(P);
                SetEnemySpeed(P, 370,370,370);
                SetEnemyInvestigation(P);
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
                Soldier =Spawn(Class'OLEnemySoldier',,'Mate',P.Location,P.Rotation,,true);
                Kill(P);
                SetStaticEnemyValues(Soldier);
                SetEnemyInvestigation(Soldier);
                SetEnemySpeed(Soldier, 450,500,750);
                if(InRange(Vect(-1030.0917, -8681.7715, -846.3397), Soldier.Location, 300))
                {
                    SetEnemyAttackAndDoor(Soldier);
                }
                else
                {
                    SetEnemyAttackAndDoor(Soldier,,200,,,4);
                }
                SetEnemyVisionAndHearing(Soldier, EVT_Normal);
                Soldier.Modifiers.bShouldAttack =true;
                Bot =Spawn(Class'OLBot');
                Bot.Possess(Soldier, false);
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
                SetStaticEnemyValues(P);
                SetEnemyAttackAndDoor(P,,,,,,,,,,,50);
                SetEnemySpeed(P, 500,500,500);
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
                    Kill(P);
                    I++;
                    continue;
                }
                else if(I ==1)
                {
                    P.SetLocation(Vect(-3373.0918, -9307.4551, -451.8500));
                    P.SetRotation(Rot(0, 32315, 0));
                    SetStaticEnemyValues(P);
                    SetEnemyAttackAndDoor(P);
                    SetEnemySpeed(P, 120,120,120);
                    P.Tag ='done';
                    I++;
                    Continue;
                }
                SetStaticEnemyValues(P);
                SetEnemyAttackAndDoor(P);
                SetEnemySpeed(P, 350,350,350);
                P.SetLocation(Vect(-142.7476, -7236.9209, -451.8500));
                P.Tag ='Done';
                GlobalEnemy =P;
            }
        }
        EnemyFastDoor(GlobalEnemy, 3);
        if(InRange(Vect(-1982.3485, -9303.4063, -451.8500), Location, 300))
        {   SetEnemySpeed(GlobalEnemy, 650,650,650);}
    }
    else if(CurrentCP =='Male_TortureDone')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done')
            {
                OtherLoop();
                SetGameSpeed ();
                SetStaticEnemyValues(P);
                SetEnemyInvestigation(P);
                SetEnemyAttackAndDoor(P, 1000);
                SetEnemyVisionAndHearing(P, EVT_EPEule);
                SetEnemySpeed(P, 800, 800, 900);
                P.SetOnlyOwnerSee(true);
                GlobalEnemy =P;
                P.Tag ='Done';
            }
        }
        EnemyFastdoor(GlobalEnemy, 4);
    }
    else if(CurrentCP =='Male_Surgeon')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='done')
            {
                SetStaticEnemyValues(P);
                SetEnemyInvestigation(P);
                SetEnemyAttackAndDoor(P, 1000);
                SetEnemyVisionAndHearing(P, EVT_EPEule);
                SetEnemySpeed(P, 200, 800, 850);
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
                SetStaticEnemyValues(P);
                SetEnemyInvestigation(P); 
                // 4, 200.0, 600.0, 60.0, 1200.0, 10.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, false, true, true);
                SetEnemyAttackAndDoor(P, 200);
                SetEnemyVisionAndHearing(P, EVT_EPEule);
                SetEnemySpeed(P, 325, 800, 850);
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
                SetStaticEnemyValues(Soldier);
                SetEnemyInvestigation(Soldier); 
                SetEnemyAttackAndDoor(Soldier,,300,,,4.0);
                SetEnemyVisionAndHearing(Soldier, EVT_EPAlt);
                if(!CB1)
                {    SetEnemySpeed(Soldier, 240, 500, 650);}
                else
                {   SetEnemySpeed(Soldier, 240, 325, 500);}
                Soldier.Tag ='Done';
                GlobalEnemy =Soldier;
            }
        }
        EnemyFastDoor(GlobalEnemy, 2);
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
                SetEnemySpeed(p, 900,900,900);
                Walrider =Spawn(Class'OLEnemyNanoCloud',,'EPA',P.Location,P.Rotation,,true);
                SetStaticEnemyValues(Walrider);
                SetEnemySpeed(Walrider,,500,750);
                SetEnemyInvestigation(Walrider);
                SetEnemyAttackAndDoor(Walrider,200,200);
                SetEnemyVisionAndHearing(Walrider, EVT_EPAlt);
                Walrider.Modifiers.bShouldAttack =true;
                Bot =Spawn(Class'OLBot');
                Bot.Possess(Walrider,false);
                GlobalEnemy =Walrider;
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
                SetStaticEnemyValues(Soldier);
                SetEnemySpeed(Soldier,750,750,750);
                SetEnemyAttackAndDoor(Soldier, 800);
                Nohide(Soldier);
                Soldier.Tag ='Done';                
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
                SetStaticEnemyValues(Soldier);
                SetEnemyVisionAndHearing(Soldier, EVT_EPAlt,1500);
                SetEnemyInvestigation(Soldier);
                SetEnemySpeed(Soldier,190,750,750);
                SetEnemyAttackAndDoor(Soldier, 800);
                Soldier.Tag ='Done';                
            }
        }
    }
    else if(CurrentCP =='Female_2ndFloor' || CurrentCP =='Female_2ndfloorChute')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(!CB1 && P.ISA('OLEnemyGenericPatient_B'))
            {
                SetStaticEnemyValues(P);
                SetEnemySpeed(P, 350, 750, 850);
                SetEnemyVisionAndHearing(p, EVT_EPEule);
                SetEnemyAttackAndDoor(P,1000);
                SetEnemyInvestigation(P);
                P.SetOnlyOwnerSee(true);
                CB1 =true;
                GlobalEnemy =P;
                SetTimer(5, false, 'PCH');
                SetGameSpeed();
            }
            if(CB1)
            {
                EnemyFastDoor(GlobalEnemy, 4);
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
            Soldier =spawn(Class'OLEnemyGroom',,,Vect(-3326.8953, 8845.6758, 350.1505),Rot(0, -17909, 0),,true);
            SetStaticEnemyValues(Soldier);
            SetEnemySpeed(Soldier, 750,750,750);
            SetEnemyAttackAndDoor(Soldier,,200);
            SetEnemyAttackAndDoor(GlobalEnemy,1000,200,,,,,,30);
            Soldier.Mesh.SetSkeletalMesh(SkeletalMesh'DLC_Build2Exterior-01_LD.02_Groom.Groom_Shirt');
            Soldier.Modifiers.bUseForMusic =true;
            Soldier.Modifiers.bShouldAttack =true;
            Bot =Spawn(Class'OLBot');
            Bot.Possess(Soldier,false);
            GlobalEnemyA =Soldier;
            ExposePosition(GlobalEnemyA, 600);
        }
        EnemyFastDoor(GlobalEnemyA, 2);
    }
    else if(CurrentCP =='Female_KeyPickedup' || CurrentCP =='Female_3rdFloor')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done' && !P.ISA('OLEnemyGenericPatient_G'))
            {
                SetStaticEnemyValues(P);
                SetEnemySpeed(P, 400, 750, 750);
                SetEnemyVisionAndHearing(P, EVT_EPAlt);
                SetEnemyAttackAndDoor(P, 1000, 200);
                SetEnemyInvestigation(P);
                P.SetOnlyOwnerSee(true);
                P.Tag ='Done';
                GlobalEnemy =P;
            }
        }
        EnemyFastDoor(GlobalEnemy, 4);
    }
    else if(CurrentCP =='Female_3rdFloorPosthole')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done' && P.IsA('OLEnemyGenericPatient_G'))
            {
                P.SetCollision(false,false,false);
                SetStaticEnemyValues(P);
                SetEnemySpeed(P, 700, 750,750);
                SetEnemyVisionAndHearing(P, EVT_EPEule);
                SetEnemyAttackAndDoor(P, 1000,200);
                SetEnemyInvestigation(P);
                P.SetOnlyOwnerSee(true);
                P.SetLocation(Vect(-6348.9712, 10545.0332, 998.1505));
                P.Tag ='Done';
            }
        }
    }
    else if(CurrentCP =='Female_LostCam')
    {   EnemyFastDoor(GlobalEnemy, 4);}
    else if(CurrentCP =='Female_FoundCam')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done' && P.Modifiers.bShouldAttack)
            {
                if(!CB1)
                {  
                    Kill(P);
                    CB1=true;
                    continue;
                }
                SetStaticEnemyValues(P);
                SetEnemySpeed(P, 480,480,480);
                SetEnemyAttackAndDoor(P);
                SetEnemyVisionAndHearing(P, EVT_EPEule);
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
                SetStaticEnemyValues(P);
                SetEnemyVisionAndHearing(P, EVT_EPAlt);
                SetEnemyInvestigation(P);
                SetEnemySpeed(P, 120,150,450);
                SetEnemyAttackAndDoor(P);
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
                SetStaticEnemyValues(Soldier);
                SetEnemySpeed(Soldier, 250, 600, 650);
                SetEnemyVisionAndHearing(Soldier, EVT_EPEule);
                SetEnemyInvestigation(Soldier);
                SetEnemyAttackAndDoor(Soldier,800,500);
                Soldier.Tag ='Done';
            }
            EnemyFastDoor(Soldier, 2.5);
        }
    }
    else if(CurrentCP =='Revisit_Mezzanine')
    {   EnemyFastDoor(GlobalEnemy, 3.5);}
    else if(CurrentCP =='Revisit_RH')
    {   EnemyFastDoor(GlobalEnemy, 1.75);}
    else if(CurrentCP =='Revisit_FoundKey')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag !='Done' && P.IsA('OLEnemyGenericPatient_G'))
            {
                SetStaticEnemyValues(P);
                SetEnemyVisionAndHearing(P,EVT_EPEule);
                SetEnemyAttackAndDoor(P,1000);
                SetEnemySpeed(P,900,900,900);
                SetEnemyInvestigation(P);
                P.SetOnlyOwnerSee(true);
            }
            EnemyFastDoor(P,2.5);
        }
    }
    else if(CurrentCP =='Revisit_Soldier3')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemySoldier', Soldier)
        {
            if(Soldier.Tag !='Done')
            {
                SetStaticEnemyValues(Soldier);
                SetEnemySpeed(Soldier, 530,680,900,,,565);
                SetEnemyAttackAndDoor(Soldier, 800);
                Soldier.SetOnlyOwnerSee(true);
                ExposePosition(Soldier, 20);
                Soldier.Tag ='Done';
            }
        }
    }
    else if(CurrentCP =='Lab_SwarmIntro2')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyNanoCloud', Walrider)
        {
            if(Walrider.Tag !='Done')
            {
                SetEnemySpeed(Walrider, 10,10,10);
                SetEnemyAttackAndDoor(Walrider,,200,0.0,0.0,3600,0.0, 0.0, 0.0, 0.0,0);
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
                SetStaticEnemyValues(Walrider);
                SetEnemyAttackAndDoor(Walrider, 500);
                SetEnemySpeed(Walrider, 900,400,750);
                SetEnemyInvestigation(Walrider);
                SetEnemyVisionAndHearing(Walrider, EVT_EPEule);
                Walrider.Tag ='Done';
                GlobalEnemy =Walrider;
            }
        }
    }
    else if(CurrentCP =='Lab_BigRoomDone')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyNanoCloud', Walrider)
        {
            if(Walrider.Tag !='Done')
            {
                SetStaticEnemyValues(Walrider);
                SetEnemyAttackAndDoor(Walrider,200);
                SetEnemySpeed(Walrider,500,500,500);
                Walrider.SetCollision(false,false,false);
            }
        }
    }
    else if(CurrentCP =='Lab_BigTowerStairs')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            if(P.Tag =='Dodge')
            {   Kill(P); Continue;}
            if(P.IsA('OLEnemyNanoCloud_A'))
            {
                Kill(P);
                GlobalEnemy =Spawn(Class'OLEnemyNanoCloud',,'FastFertig',P.Location,P.Rotation,,true);
                SetStaticEnemyValues(GlobalEnemy);
                SetEnemyVisionAndHearing(GlobalEnemy,EVT_EPEule);
                SetEnemyAttackAndDoor(GlobalEnemy,200);
                SetEnemySpeed(GlobalEnemy,,,450);
                GlobalEnemy.Modifiers.bShouldAttack =true;
                Bot =Spawn(Class'OLBot');
                Bot.Possess(GlobalEnemy,false);
                Continue;
            }
            if(GlobalEnemy !=None && InRange(Vect(-26593.3398, 1898.1426, -891.8499), Location, 70))
            {   Kill(GlobalEnemy);}
            if(P.Tag !='FastFertig')
            {
                SetStaticEnemyValues(P);
                SetEnemyAttackAndDoor(P,200);
                SetEnemySpeed(P,500,500,500);
                P.Tag ='FastFertig';
            }
        }
    }
    else if(CurrentCP =='Lab_BigTowerDone')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyNanoCloud',Walrider)
        {
            Kill(Walrider);
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
            Kill();
            ClearTimer('SubLoop');
            I =0;
        }
    }
    else if(CurrentCP =='Admin_SecurityRoom')
    {
        ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', P)
        {
            EnemyFastDoor(P, 3.75);
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
            GlobalEnemy =Spawn(Class'OLEnemyNanoCloud', ,,Vect(-6729.4019, -870.7884, -651.8499), ,,true);
            SetStaticEnemyValues(GlobalEnemy);
            SetEnemyAttackAndDoor(GlobalEnemy, 200);
            SetEnemySpeed(GlobalEnemy, 700,700,420);
            GlobalEnemy.Modifiers.bShouldAttack=true;
            Bot =Spawn(Class'OLBot');
            Bot.Possess(GlobalEnemy, false);
            GlobalEnemy.Bot.SightComponent.bAlwaysSeeTarget=true;
        }
    }
    else if(CurrentCP =='Admin_Basement')
    {
        EnemyFastDoor(GlobalEnemy, 2.5);
        if(!CB2 && InRange(Vect(-6505.2329, 2924.3276, -551.8500), Location, 120))
        {
            SetEnemySpeed(GlobalEnemy, 201, 700, 800, 201, 750, 900);
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
        GlobalEnemy =Spawn(Class'OLEnemyGenericPatient',,'EPA', Vect(3596.1333, 1991.8582, 998.1500), Rot(0, -17708, 0),,true);
        SetStaticEnemyValues(GlobalEnemy);
        SetEnemyAttackAndDoor(GlobalEnemy, 300,,,,1.0);
        SetEnemySpeed(GlobalEnemy, 400,400,800);
        GlobalEnemy.Modifiers.bShouldAttack=true;
        GlobalEnemy.Modifiers.WeaponToUse =Weapon_Machete;
        GlobalEnemy.ApplyModifiers(GlobalEnemy.Modifiers);
        GlobalEnemy.BehaviorTree =OLBTBehaviorTree'Prison_01-LD.02_AI_Behaviors.Generic_FullLoop_BT';
        GlobalEnemy.Mesh.SetSkeletalMesh(SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_19');
        Bot =Spawn(Class'OLBot');
        Bot.Possess(GlobalEnemy,false);
    }
    // SewerESL
    else if(CurrentCP =='Sewer_start')
    {
        GlobalEnemy =Spawn(Class'OLEnemyNanoCloud',,'EPA',Vect(4406.8799, 4585.3325, -401.8301),Rot(0, -17239, 0),,true);
        SetStaticEnemyValues(GlobalEnemy);
        SetEnemySpeed(GlobalEnemy, 520,520,520);
        SetEnemyAttackAndDoor(GlobalEnemy, 800.0,   250.0, 1.0, 15, 0.01, 0.0, 0.0, 0.0, 0.0, 0, 3);
        GlobalEnemy.Modifiers.bShouldAttack=true;
        GlobalEnemy.BehaviorTree=OLBTBehaviorTree'02_AI_Behaviors.Soldier_BT';
        Bot =Spawn(Class'OLBot');
        Bot.Possess(GlobalEnemy,false);
    }
    else if(CurrentCP =='Sewer_PostCitern')
    {
        GlobalEnemy =Spawn(Class'OLEnemyGenericPatient',,'Mate', Vect(-3291.5776, -5156.1479, -401.8497), Rot(0, -18215, 0),,true);
        SetStaticEnemyValues(GlobalEnemy);
        SetEnemySpeed(GlobalEnemy, 500,500,500);
        SetEnemyAttackAndDoor(GlobalEnemy);
        GlobalEnemy.Modifiers.bShouldAttack =true;
        GlobalEnemy.Modifiers.WeaponToUse =Weapon_Knife;
        GlobalEnemy.ApplyModifiers(GlobalEnemy.Modifiers);
        GlobalEnemy.BehaviorTree =OLBTBehaviorTree'Prison_01-LD.02_AI_Behaviors.Generic_FullLoop_BT';
        GlobalEnemy.mesh.SetskeletalMesh(SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_19');
        Bot =Spawn(Class'OLBot');
        Bot.Possess(GlobalEnemy,false);
        NoHide(GlobalEnemy);
    }
    // Male ESL
    // Courtyard ESL
    // Female ESL
    else if(CurrentCP =='Female_LostCam')
    {
        GlobalEnemy =Spawn(Class'OLEnemyGenericPatient',,'Done', Vect(-4803.6523, 9873.1973, 548.1505),Rot(0, -15158, 0),,true);
        SetStaticEnemyValues(GlobalEnemy);
        SetEnemySpeed(GlobalEnemy,700,700,700);
        SetEnemyVisionAndHearing(GlobalEnemy, EVT_EPEule, 10000);
        SetEnemyAttackAndDoor(GlobalEnemy,,200);
        GlobalEnemy.Mesh.SetSkeletalMesh(SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_19');
        GlobalEnemy.BehaviorTree =OLBTBehaviorTree'Prison_01-LD.02_AI_Behaviors.Generic_FullLoop_BT';
        GlobalEnemy.Modifiers.bShouldAttack =true;
        GlobalEnemy.Modifiers.WeaponToUse =Weapon_Knife;
        GlobalEnemy.ApplyModifiers(GlobalEnemy.Modifiers);
        Bot =Spawn(Class'OLBot');
        Bot.Possess(GlobalEnemy,false);
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
        GlobalEnemy =Spawn(Class'OLEnemyGroom',,'EPA',Vect(-7325.9512, 749.8629, 550.0381),Rot(0, -24696, 0),,true);
        SetStaticEnemyValues(GlobalEnemy);
        SetEnemyVisionAndHearing(GlobalEnemy, EVT_EPEule);
        SetEnemySpeed(GlobalEnemy,,700,800);
        SetEnemyInvestigation(GlobalEnemy);
        SetEnemyAttackAndDoor(GlobalEnemy);
        GlobalEnemy.Mesh.SetSkeletalMesh(SkeletalMesh'DLC_Build2Exterior-01_LD.02_Groom.Groom_Shirt');
        GlobalEnemy.Modifiers.bShouldAttack =true;
        Bot=Spawn(Class'OLBot');
        Bot.Possess(GlobalEnemy,false);
    }
    else if(CurrentCP =='Revisit_RH' && Inrange(Vect(-5461.3047, 437.6146, 365.1656), Location, 110))
    {
        ClearTimer('SubLoop');
        GlobalEnemy =Spawn(Class'OLEnemyNanoCloud',,,Vect(-4458.0947, 901.7354, 365.1656),Rot(0, -32746, 0),,true);
        SetStaticEnemyValues(GlobalEnemy);
        SetEnemySpeed(GlobalEnemy,1000,1000,1000);
        SetEnemyAttackAndDoor(GlobalEnemy);
        GlobalEnemy.Modifiers.bShouldAttack =true;
        Bot=Spawn(Class'OLBot');
        Bot.Possess(GlobalEnemy,false);
        NoHide(GlobalEnemy);
    }
    else if(CurrentCP =='Lab_BigRoomDone')
    {
        GlobalEnemy =Spawn(Class'OLEnemySoldier',,'Dodge',Vect(-23377.5762, -5673.4341, -4301.8501),Rot(0, -17632, 0),,true);
        SetStaticEnemyValues(GlobalEnemy);
        SetEnemySpeed(GlobalEnemy,0,10,450);
        SetEnemyAttackAndDoor(GlobalEnemy);
        SetEnemyVisionAndHearing(GlobalEnemy, EVT_EPEule);
        SetEnemyInvestigation(GlobalEnemy);
        GlobalEnemy.Modifiers.bShouldAttack =true;
        Bot=Spawn(Class'OLBot');
        Bot.Possess(GlobalEnemy,false);
        
        GlobalEnemy =Spawn(Class'OLEnemySoldier',,'Dodge',Vect(-23850.9941, -4863.2378, -4301.8496),Rot(0, -6619, 0),,true);
        SetStaticEnemyValues(GlobalEnemy);
        SetEnemySpeed(GlobalEnemy,0,10,450);
        SetEnemyAttackAndDoor(GlobalEnemy);
        SetEnemyVisionAndHearing(GlobalEnemy, EVT_EPEule);
        SetEnemyInvestigation(GlobalEnemy);
        GlobalEnemy.Modifiers.bShouldAttack =true;
        Bot=Spawn(Class'OLBot');
        Bot.Possess(GlobalEnemy,false);
        
        GlobalEnemy =Spawn(Class'OLEnemySoldier',,'Dodge',Vect(-23248.8262, -2088.1570, -4301.8501),Rot(0, -21109, 0),,true);
        SetStaticEnemyValues(GlobalEnemy);
        SetEnemySpeed(GlobalEnemy,0,20,450);
        SetEnemyAttackAndDoor(GlobalEnemy);
        SetEnemyVisionAndHearing(GlobalEnemy, EVT_EPEule);
        SetEnemyInvestigation(GlobalEnemy);
        GlobalEnemy.Modifiers.bShouldAttack =true;
        Bot=Spawn(Class'OLBot');
        Bot.Possess(GlobalEnemy,false);

        GlobalEnemy =Spawn(Class'OLEnemySoldier',,'Dodge',Vect(-24142.0098, -612.3654, -4121.1729),Rot(0, -7365, 0),,true);
        SetStaticEnemyValues(GlobalEnemy);
        SetEnemySpeed(GlobalEnemy,0,30,450);
        SetEnemyAttackAndDoor(GlobalEnemy);
        SetEnemyVisionAndHearing(GlobalEnemy, EVT_EPEule);
        SetEnemyInvestigation(GlobalEnemy);
        GlobalEnemy.Modifiers.bShouldAttack =true;
        Bot=Spawn(Class'OLBot');
        Bot.Possess(GlobalEnemy,false);

        /*
        GlobalEnemy =Spawn(Class'OLEnemySoldier',,'Dodge',Vect(-24999.4668, 945.9188, -3751.8501),Rot(0, 17017, 0),,true);
        SetStaticEnemyValues(GlobalEnemy);
        SetEnemySpeed(GlobalEnemy,0,0,450);
        SetEnemyAttackAndDoor(GlobalEnemy);
        SetEnemyVisionAndHearing(GlobalEnemy, EVT_Normal);
        SetEnemyInvestigation(GlobalEnemy);
        GlobalEnemy.Modifiers.bShouldAttack =true;
        Bot=Spawn(Class'OLBot');
        Bot.Possess(GlobalEnemy,false);
        */
    }
    else if(CurrentCP =='Lab_BigTowerDone')
    {
        While(I<9)
        {
            GlobalEnemy=Spawn(Class'OLEnemySurgeon',,'Meme',Vect(-24995.2031, 1083.2507, -3751.8501),,,true);
            GlobalEnemy.SetCollision(false,false,false);
            SetStaticEnemyValues(GlobalEnemy);
            SetEnemySpeed(GlobalEnemy,500,500,500);
            SetEnemyAttackAndDoor(GlobalEnemy,,200,0.0,0.0,0.01,0.0, 0.0, 0.0, 0.0,0);
            GlobalEnemy.AttackNormalKnockbackPower =0;
            GlobalEnemy.Modifiers.bShouldAttack =true;
            GlobalEnemy.Modifiers.WeaponToUse =Weapon_BoneShear;
            GlobalEnemy.ApplyModifiers(GlobalEnemy.Modifiers);
            GlobalEnemy.BehaviorTree =OLBTBehaviorTree'Male_ward_03_LD.02_AI_Behaviors.Surgeon_FullLoop_BT';
            GlobalEnemy.Mesh.SetSkeletalMesh(SkeletalMesh'Male_ward_SE.02_Surgeon.Mesh.Surgeon');
            Bot=Spawn(Class'OLBot');
            Bot.Possess(GlobalEnemy,false);
            NoHide(GlobalEnemy);
            EnemyAnimRate(GlobalEnemy, 2);
            I++;
        }
    }
}

/**********Hero Functions**********/

Function HeroLoop()
{
    // AdminHL
    if(ValidCP('Admin_Gates'))
    {
        LastCP =CurrentCP;
        SetTimer(0.5, false, 'HeroSubLoop');
        SetPlayerSpeed();
        SetJumpPunishment();
    }
    else if(ValidCP('Admin_Mezzanine'))
    {
        LastCP =CurrentCP;
        SetJumpPunishment(90, 20);
        SetPlayerSpeed(,,330);
        SetTimer(0.1, true, 'HeroSubLoop');
    }
    else if(ValidCP('Admin_MainHall') || ValidCP('Admin_WheelChair'))
    {
        LastCP =CurrentCP;
        SetJumpPunishment();
        SetPlayerSpeed();
        SetGameSpeed(3);
        if(CurrentCP =='Admin_WheelChair')
        {
            SetTimer(0.2, true, 'HeroSubLoop');
        }
    }
    else if(ValidCP('Admin_Securityroom'))
    {
        LastCP =CurrentCP;
        SetJumpPunishment(95, 8);        
        SetPlayerSpeed(50,110,330);
    }
    else if(ValidCP('Admin_Basement'))
    {
        LastCP =CurrentCP;
        CB1 =false;
        CB2 =false;
        ClearTimer('SubLoop');
        Kill();
        SetPlayerSpeed(50, 110, 330);
        SetJumpPunishment(101, 10);        
        SetTimer(2.0, false, 'OtherLoop');
    }
    else if(ValidCP('Admin_PostBasement'))
    {
        LastCP =CurrentCP;
        CB1 =false;
        CB2 =false;
        ClearTimer('SubLoop');
        ClearTimer('HeroSubLoop');
        SetPlayerSpeed(,,700);
        SetJumpPunishment();
    }
    // PrisonHL
    else if(ValidCP('Prison_Start'))
    {
        LastCP =CurrentCP;
        SetPlayerSpeed(50, 110, 330,);
        SetJumpPunishment(101, 10);
        SetTimer(0.2, true, 'HeroSubLoop');
    }
    else if(ValidCP('Prison_ToPrisonFloor'))
    {
        LastCP =CurrentCP;
        SetPlayerSpeed();
        SetJumpPunishment();
        CB1 =false;
        ClearTimer('HeroSubLoop');
        Kill();
        Controller.bHasCamcorder=false;
        SetTimer(0.5, false, 'HeroSubLoop');
    }
    else if(ValidCP('Prison_PrisonFloor_3rdFloor'))
    {
        LastCP =CurrentCP;
        SetJumpPunishment(101, 0.02);
        SetPlayerSpeed(50,110,350);
        Controller.bHasCamcorder=true;
        SetBrightness();
        SetTimer(0.3, true, 'HeroSubLoop');
    }
    else if(ValidCP('Prison_PrisonFloor_SecurityRoom1'))
    {
        LastCP =CurrentCP;
        SetJumpPunishment(101, 10);
        SetPlayerSpeed(50,110,350);
        SetTimer(2, false, 'OtherLoop');
    }
    else if(ValidCP('Prison_PrisonFloor02_IsolationCells01'))
    {
        LastCP =CurrentCP;
        SetJumpPunishment(101, 10);
        SetPlayerSpeed(50,110,240);
        Cb1 =false;
        CB2 =false;
        Controller.bCPActive=false;
        InitAmpel();
    }
    else if(ValidCP('Prison_Showers_2ndFloor'))
    {
    LastCP =CurrentCP;
    SetJumpPunishment(101, 10);
    SetPlayerSpeed(50,110,330);
    InitAmpel(false);
    }
    else if(ValidCP('Prison_PrisonFloor02_PostShowers'))
    {
    LastCP =CurrentCP;
    SetJumpPunishment(0, 10);
    SetPlayerSpeed();
    SetGameSpeed(2.5);
    }
    else if(ValidCP('Prison_PrisonFloor02_SecurityRoom2'))
    {
    LastCP =CurrentCP;
    SetGameSpeed();
    SetJumpPunishment(60, 8);
    SetPlayerSpeed(55, 110, 300);
    SetTimer(1, false, 'OtherLoop');
    }
    else if(ValidCP('Prison_IsolationCells02_Soldier'))
    {
    LastCP =CurrentCP;
    SetJumpPunishment(60, 6);
    SetPlayerSpeed(55, 110, 350);
    }
    else if(ValidCP('Prison_IsolationCells02_PostSoldier'))
    {
        LastCP =CurrentCP;
        SetJumpPunishment(101, 2);
        SetPlayerSpeed(55, 110, 330);
        SetTimer(3, false, 'OtherLoop');
    }
    else if(ValidCP('Prison_OldCells_PreStruggle'))
    {
        LastCP =CurrentCP;
        SetJumpPunishment(90, 5);
        SetPlayerSpeed(55, 110, 330);
        SetTimer(0.025, false, 'OtherLoop');
        SetTimer(0.2, true, 'HeroSubLoop');
        if(GlobalEnemyA !=None)
        {   Kill(GlobalEnemyA);}
    }
    else if(ValidCP('Prison_OldCells_PreStruggle2'))
    {
        LastCP =CurrentCP;
        SetJumpPunishment(101, 0.02);
        SetPlayerSpeed(75,200,200);
        SetTimer(1, false, 'OtherLoop');
        if(GlobalEnemy !=None)
        {
            Kill(GlobalEnemy);
        }
    }
    else if(ValidCP('Prison_Showers_Exit'))
    {
        LastCP =CurrentCP;
        SetJumpPunishment();
        SetPlayerSpeed();
        SetTimer(1, false, 'OtherLoop');
        Kill();
    }
    // SewerHL
    else if(ValidCP('Sewer_start'))
    {
        LastCP =CurrentCP;
        SetJumpPunishment(101,0.02);
        SetPlayerSpeed(55,110,330);
        SetTimer(3, false, 'SubLoop');
    }
    else if(ValidCP('Sewer_FlushWater'))
    {
        LastCP =CurrentCP;
        SetJumpPunishment(101,0.02);
        SetPlayerSpeed(55,110,330);
        if(GlobalEnemy !=None)
        {   Kill(GlobalEnemy);}
        SetTimer(1, false, 'OtherLoop');
        SetTimer(0.2, true, 'HeroSubLoop');
    }
    else if(ValidCP('Sewer_Ladder') || ValidCP('Sewer_ToCitern') || ValidCP('Sewer_Citern1'))
    {
        LastCP =CurrentCP;
        SetJumpPunishment();
        SetPlayerSpeed(120);
        CB1 =false; CB2 =false; CBOther =false;
        ClearTimer('HeroSubLoop');
        ClearTimer('StartBonus');
        ClearTimer('NoBonus');
        SetGameSpeed(1.5);
    }
    else if(ValidCP('Sewer_Citern2'))
    {
        LastCP =CurrentCP;
        SetJumpPunishment(101, 0.02);
        SetPlayerSpeed(,,330);
        SetGameSpeed();
        SetTimer(0.1, true, 'HeroSubLoop');
    }
    else if(ValidCP('Sewer_PostCitern'))
    {
        if(GlobalEnemy !=None)
        {   Kill(GlobalEnemy);}
        if(IsTimerActive('HeroSubLoop'))
        {   ClearTimer('HeroSubLoop');}
        LastCP =CurrentCP;
        SetJumpPunishment(101, 0.02);
        SetPlayerSpeed(55,110,370);
        SetTimer(0.5, false, 'SubLoop');
    }
    else if(ValidCP('Sewer_ToMaleWard'))
    {
        LastCP =CurrentCP;
        ClearTimer('SubLoop');
        if(GlobalEnemy !=None)
        {   GlobalEnemy.modifiers.bShouldAttack =false;}
        SetPlayerSpeed();
        // 68 Jahre...
        SetJumpPunishment(35, MaxInt);
    }
    // MaleHL
    else if(ValidCP('Male_Start'))
    {
        LastCP =CurrentCP;
        Kill();
        SetPlayerSpeed();
        SetJumpPunishment();
    }
    else if(ValidCP('Male_Chase'))
    {
        LastCP =CurrentCP;
        SetPlayerSpeed(55, 110, 350);
        SetJumpPunishment(101, 0.02);
        SetTimer(1, false, 'OtherLoop');
        SetTimer(0.1, true, 'HeroSubLoop');
    }
    else if(ValidCP('Male_ChasePause'))
    {
        LastCP =CurrentCP;
        SetPlayerSpeed(55, 110, 330);
        SetJumpPunishment(1, 0.02);
        SetTimer(0.15, false,'HeroSubLoop');
        SetTimer(1, false, 'OtherLoop');
    }
    else if(ValidCP('Male_Torture'))
    {
        LastCP =CurrentCP;
        I =0;
        Healing(MaxInt, 0.02);
        if(EPGame(WorldInfo.Game).DifficultyMode !=EDM_Insane)
        {
            InitBMSG("LeftClick to skip cutscene.", SoundCue'EPlusAssets.Sound.PopUp_Cue', 15, 0.2);
            SetTimer(1, false, 'HeroSubLoop');
        }
    }
    else if(ValidCP('Male_TortureDone'))
    {
        LastCP =CurrentCP;
        if(GlobalEnemy !=none)
        {   Kill(GlobalEnemy);}
        ClearTimer('HeroSubLoop');
        if(EPHud(Controller.Hud).DisplayMsg)
        {   EPHud(Controller.Hud).DisplayMsg =false;}
        SetPlayerSpeed(55, 110, 330);
        SetJumpPunishment(101, 0.02);
        Controller.bHasCamcorder =false;
        SetGameSpeed(3);
    }
    else if(ValidCP('Male_Surgeon'))
    {
        LastCP =CurrentCP;
        if(GlobalEnemy !=none)
        {   Kill(GlobalEnemy);}
        SetPlayerSpeed(55, 110, 350);
        SetJumpPunishment(101, 0.02);
        Controller.bHasCamcorder =false;
        SetTimer(0.1, true, 'HeroSubLoop');
        SetTimer(1, false, 'OtherLoop');
    }
    else if(ValidCP('Male_GetTheKey'))
    {
        LastCP =CurrentCP;
        if(GlobalEnemy !=none)
        {   Kill(GlobalEnemy);}
        if(IsTimerActive('HeroSubLoop'))
        {   ClearTimer('HeroSubLoop');}
        SetPlayerSpeed(55, 110, 330);
        SetJumpPunishment(101, 0.02);
        Controller.bHasCamcorder =false;
        SetTimer(0.1, false, 'OtherLoop');
    }
    else if(ValidCP('Male_ElevatorDone') || ValidCP('Male_Priest') || ValidCP('Male_Cafeteria'))
    {
        LastCP =CurrentCP;
        SetPlayerSpeed(,,850);
        SetJumpPunishment();
        Controller.bHasCamcorder =true;
        if(CurrentCP =='Male_Cafeteria')
        {   SetTimer(0.1, true, 'HeroSubLoop');}
    }
    else if(ValidCP('Male_SprinklerOff'))
    {
        LastCP =CurrentCP;
        CB1 =false;
        SetPlayerSpeed(55,110,350);
        SetJumpPunishment(60, 4);
        SetTimer(1, false, 'OtherLoop');
        SetTimer(170, false, 'KillSelf');
        SetTimer(0.1, true, 'HeroSubLoop');
    }
    else if(ValidCP('Male_SprinklerOn'))
    {   
        LastCP =CurrentCP;
        SetJumpPunishment(101,0.02);
        if(GlobalEnemy !=None)
        {   
            SetEnemyAttackAndDoor(GlobalEnemy, 1000);
            SetEnemySpeed(GlobalEnemy, 240,500,800);
            SetEnemyVisionAndHearing(GlobalEnemy, EVT_EPEule);
        }
    }
    // Courtyard HL
    // Nichts tun
    else if(ValidCP('Courtyard_Start') || ValidCP('Courtyard_Corridor') || ValidCP('Courtyard_Chapel') || ValidCP('Courtyard_FemaleWard') || ValidCP('Female_Start') || ValidCP('Admin_Garden') || ValidCP('Admin_Explosion') || ValidCP('Female_Chasedone') || ValidCP('Female_Exit') || ValidCP('Revisit_ToLab') || ValidCP('Lab_BigTowerMid'))
    {
        LastCP =CurrentCP;
        SetPlayerSpeed();
        SetJumpPunishment();
    }
    else if(ValidCP('Courtyard_Soldier1'))
    {
        LastCP =CurrentCP;
        if(GlobalEnemy !=None)
        {   Kill(GlobalEnemy);}
        SetPlayerSpeed(55,110,330);
        SetJumpPunishment(99,10);
    }
    else if(ValidCP('Courtyard_Soldier2'))
    {
        LastCP =CurrentCP;
        SetPlayerSpeed(55,110,350);
        SetJumpPunishment(101,0.02);
    }
    else if(ValidCP('Female_Mainchute'))
    {
        LastCP =CurrentCP;
        SetPlayerSpeed(55,110,350);
        SetJumpPunishment(101,0.02);
        bHobbling =true;
    }
    else if(ValidCP('Female_2ndFloor') || ValidCP('Female_2ndfloorChute'))
    {
        LastCP =CurrentCP;
        SetPlayerSpeed(55,110,330);
        SetJumpPunishment(101,100);
        bHobbling =false;
        SetTimer(1, false,'OtherLoop');
        SetGameSpeed(2);
    }
    else if(ValidCP('Female_ChuteActivated'))
    {
        LastCP =CurrentCP;
        SetJumpPunishment(101,0.02);
        SetPlayerSpeed(55,110,370);
        Controller.AIChaseMusicTimeDelay =0.5;
        Controller.AIChaseMusicTimer =0.4;
    }
    else if(ValidCP('Female_Keypickedup'))
    {
        LastCP =CurrentCP;
        SetJumpPunishment(101,0.02);
        SetPlayerSpeed(55,110,330);
        Controller.AIChaseMusicTimeDelay =MaxInt;
        SetTimer(0.2, true, 'HeroSubLoop');
        SetTimer(1, false,'OtherLoop');
        if(GlobalEnemyA !=None)
        {   Kill(GlobalEnemyA);}
    }
    else if(ValidCP('Female_3rdFloor'))
    {
        LastCP =CurrentCP;
        bHobbling =true;
        SetPlayerSpeed();
        SetJumpPunishment(101,0.02);
        SetTimer(1, false, 'OtherLoop');
        SetTimer(0.1, true, 'HeroSubLoop');
    }
    else if(ValidCP('Female_3rdFloorHole'))
    {
        LastCP =CurrentCP;
        bHobbling =false;
        SetPlayerSpeed();
        SetJumpPunishment();
        if(IsTimerActive('HeroSubLoop'))
        {   ClearTimer('HeroSubLoop');}
    }
    else if(ValidCP('Female_3rdFloorPosthole'))
    {
        LastCP =CurrentCP;
        SetPlayerSpeed(55,110,330);
        SetJumpPunishment(101,0.02);
        SetTimer(1, false, 'OtherLoop');
        SetTimer(0.5, false, 'BackPawnCol');
    }
    else if(ValidCP('Female_Tobigjump'))
    {
        LastCP =CurrentCP;
        SetPlayerSpeed();
        SetJumpPunishment();
    }
    else if(ValidCP('Female_LostCam'))
    {
        LastCP =CurrentCP;
        SetPlayerSpeed();
        SetJumpPunishment(45, 3);
        SetTimer(1, false, 'SubLoop');
    }
    else if(ValidCP('Female_FoundCam'))
    {
        LastCP =CurrentCP;
        SetPlayerSpeed(55,110,350);
        SetJumpPunishment(102, 0.02);
        if(GlobalEnemy !=None)
        {   Kill(GlobalEnemy);}
        SetTimer(1, false, 'OtherLoop');
        SetTimer(0.1, true, 'SubLoop');
        EPHud(Controller.Hud).TopMiddleStr ="";
    }
    else if(ValidCP('Female_Jump'))
    {
        LastCP =CurrentCP;
        CB1 =false;
        SetPlayerSpeed(,,370);
        SetJumpPunishment();
    }
    // Revisit HL
    else if(ValidCP('Revisit_Soldier1'))
    {
        LastCP =CurrentCP;
        SetPlayerSpeed(55,110,330);
        SetJumpPunishment(101,0.02);
        SetTimer(1, false, 'OtherLoop');
    }
    else if(ValidCP('Revisit_Mezzanine'))
    {
        LastCP =CurrentCP;
        SetPlayerSpeed(55,110,370);
        SetJumpPunishment(101,0.02);
        SetTimer(1, false, 'OtherLoop');
        SetTimer(0.4, false, 'SubLoop');
    }
    else if(ValidCP('Revisit_ToRH'))
    {
        LastCP =CurrentCP;
        if(GlobalEnemy !=None)
        {   Kill(GlobalEnemy);}
        SetPlayerSpeed();
        SetJumpPunishment();
    }
    else if(ValidCP('Revisit_RH'))
    {
        LastCP =CurrentCP;
        SetJumpPunishment();
        SetPlayerSpeed();
        SetTimer(0.1, true, 'SubLoop');
        SetTimer(0.11, true, 'HeroSubLoop');
    }
    else if(ValidCP('Revisit_FoundKey'))
    {
        LastCP =CurrentCP;
        SetJumpPunishment(101,0.02);
        SetPlayerSpeed(55,110,330);
        SetTimer(1,false,'OtherLoop');
        SetGameSpeed();
    }
    else if(ValidCP('Revisit_To3rdfloor') || ValidCP('Revisit_3rdFloor') || ValidCP('Revisit_RoomCrack') || ValidCP('Revisit_ToChapel') || ValidCP('Revisit_PriestDead') || ValidCP('Lab_EBlock'))
    {
        LastCP =CurrentCP;
        SetPlayerSpeed();
        SetJumpPunishment();
        SetGameSpeed(1.5);
    }
    else if(ValidCP('Revisit_Soldier3'))
    {
        LastCP =CurrentCP;
        SetPlayerSpeed(55,110,350);
        SetJumpPunishment(101,0.02);
        SetGameSpeed();
        SetTimer(1,false,'OtherLoop');
    }
    else if(ValidCP('Lab_Start'))
    {
        LastCP =CurrentCP;
        SetPlayerSpeed(55,110,330);
        SetJumpPunishment(101,0.02);
        SetTimer(0.1,true,'HeroSubLoop');
        InitAmpel(true);
    }
    else if(ValidCP('Lab_Soldierdead') || ValidCP('Lab_SpeachDone'))
    {
        LastCP =CurrentCP;
        SetPlayerSpeed();
        SetJumpPunishment();
        SetGameSpeed(3);
    }
    else if(ValidCP('Lab_SwarmCafeteria'))
    {
        LastCP =CurrentCP;
        SetJumpPunishment(101,0.02);
        SetPlayerSpeed(,,350);
        SetTimer(1, false,'OtherLoop');
        SetGameSpeed();
    }
    else if(ValidCP('Lab_ToBilly') || ValidCP('Lab_BigRoom') || ValidCP('Lab_BigRoomDone'))
    {  
        LastCP =CurrentCP;
        SetBrightness();
        SetPlayerSpeed();
        SetTimer(0.3, false,'OtherLoop');
        if(CurrentCP=='Lab_BigRoomDone')
        {   
            SetJumpPunishment(51,1.5);
            SetGameSpeed();
            SetTimer(1, false,'SubLoop');
        }
        else
        {
            SetJumpPunishment();
            SetGameSpeed(1.5);
        }
    }
    else if(ValidCP('Lab_BigTower'))
    {
        LastCP =CurrentCP;
        SetPlayerSpeed();
        SetJumpPunishment();
        SetTimer(RandRange(0.3,0.6), false, 'HeroSubLoop');
    }
    else if(ValidCP('Lab_BigTowerStairs'))
    {
        LastCP =CurrentCP;
        SetBrightness();
        SetPlayerSpeed();
        SetJumpPunishment();
        if(IsTimerActive('HeroSubLoop'))
        {   ClearTimer('HeroSubLoop');}
    }
    else if(ValidCP('Lab_BigTowerDone'))
    {
        LastCp =CurrentCP;
        SetJumpPunishment();
        SetPlayerSpeed();
        SetTimer(1, false,'OtherLoop');
        SetTimer(0.2,true,'HeroSubLoop');
        SetTimer(0.2, false,'SubLoop');
    }
}

Function HeroSubLoop()
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
                {   Kill(P);}
            }
        }
    }
    else if(CurrentCP =='Admin_WheelChair' && InRange(Vect(-6763.8232, 2858.2085, -1.8402), Location, 170))
    {
        ClearTimer('HeroSubLoop');
        SetGameSpeed(1);
    }
    // PrisonHSL
    else if(CurrentCP =='Prison_Start')
    {
        if(LocomotionMode ==LM_Cinematic)
        {
            SetGameSpeed(MaxInt);
        }
        else
        {
            SetGameSpeed();
        }
    }
    else if(CurrentCP =='Prison_ToPrisonFloor')
    {
        SetBrightness(-1000);
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
        SetEnemySpeed(GlobalEnemy,,,700);
        SetEnemyAttackAndDoor(GlobalEnemy, 400);
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
        {   SetGameSpeed(10);}
        else
        {   SetGameSpeed();}
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
            SetBrightness(-1000);
            SetJumpPunishment();
        }
        else
        {
            Controller.bHasCamcorder =true;
            SetBrightness();
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
        Kill(GlobalEnemy);
    }
    else if(CurrentCP =='Lab_Start' || CurrentCP =='Lab_PremierAirlock' || CurrentCP =='Lab_SwarmIntro' || CurrentCP =='Lab_SwarmIntro2')
    {
        if((LichtA.Tag =='Gelb' || LichtA.Tag =='Rot') && Controller.FXManager.CurrentUberPostEffect.GrainBrightness ==-1000)
        {
            SetBrightness();
        }
        else if(LichtA.Tag =='EPA' && Controller.FXManager.CurrentUberPostEffect.GrainBrightness !=-1000)
        {
            SetBrightness(-1000);
        }
        if(CurrentCP =='Lab_SwarmIntro2' && LocomotionMode ==LM_Cinematic)
        {   
            ClearTimer('HeroSubLoop'); 
            InitAmpel(false);
            SetBrightness();
        }
    }
    else if(CurrentCP =='Lab_BigTower')
    {
        SetTimer(RandRange(0.3,0.6),false,'HeroSubLoop');
        if(Controller.FXManager.CurrentUberPostEffect.GrainBrightness ==-1000)
        {   SetBrightness();}
        else
        {   SetBrightness(-1000);}
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
        Kill();
    }
}

Function CPController()
{
    // AdminCPC
    if(CurrentCP =='Admin_Basement')
    {
        TP(-8026.3477, -102.6420, -552.2194,0, 32276, 0);
    }
    else if(CurrentCP == 'Admin_Electricity')
    {
        Controller.CP("Admin_Basement");
    }
    // PrisonCPC
    else if(CurrentCP =='Prison_IsolationCells01_Mid')
    {
        Controller.CP("Prison_Start");
    }
    else if(CurrentCP =='Prison_PrisonFloor_3rdFloor')
    {
        Controller.bCPActive=false;
    }
    else if(CurrentCP =='Prison_PrisonFloor_SecurityRoom1' && !Controller.bCPActive)
    {
        Controller.CP("Prison_PrisonFloor_3rdFloor");
    }
    else if(CurrentCP =='Prison_Showers_2ndFloor')
    {
        TP(5596.3555, 2014.1335, 998.3906, 0, -625, 0);
    }
    else if(CurrentCP =='Prison_PrisonFloor02_SecurityRoom2')
    {
        Controller.CP("Prison_PrisonFloor02_PostShowers");
    }
    // SewerCPC
    else if(CurrentCP =='Sewer_WaterFlushed')
    {   Controller.CP("Sewer_FlushWater");}
    // male cpc
    else if(CurrentCP =='Male_GetTheKey2' || CurrentCP =='Male_Elevator')
    {   Controller.CP("Male_GetTheKey");}
    else if(CurrentCP =='Male_SprinklerOn')
    {   Controller.CP("Male_SprinklerOff");}
    // Courtyard CPC
    else if(CurrentCP =='Courtyard_Soldier2')
    {   TP(-4088.9114, 3072.2415, 28.1500,0, -785, 0);}
    // Female CPC
    else if(CurrentCP =='Female_ChuteActivated')
    {   Controller.CP("Female_2ndFloorChute");}
    else if(CurrentCP =='Female_3rdFloorHole')
    {   TP(-3872.3940, 10539.4268, 998.1505,0, -32084,0);}
    else if(CurrentCP =='Female_3rdFloorPosthole')
    {   Controller.CP("Female_3rdFloorHole");}
    else if(CurrentCP =='Female_FoundCam')
    {   TP(-5748.1733, 11661.5352, -1.8495,0, -17215, 0);}
    // Revisit CPC
    else if(CurrentCP =='Revisit_To3rdfloor')
    {   Controller.CP("Revisit_FoundKey");}
    else if(CurrentCP =='Lab_PremierAirlock' || CurrentCP =='Lab_SwarmIntro' || CurrentCP =='Lab_SwarmIntro2')
    {   Controller.CP("Lab_Start");}
    else if(CurrentCP =='Lab_SwarmCafeteria')
    {   TP(-17231.1387, -1123.8467, -4651.8496,0, 15332, 0);}
    else if(CurrentCP =='Lab_BigTower')
    {   Controller.CP("Lab_BigRoomDone");}
}

/**********OtherLoop**********/
Function OtherLoop()
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
    // immer brechen
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

/********** Event Chains **********/
// LocationSwap
Exec Function LocationSwap()
{
    Local Vector C, E;
    Local Rotator P, F;
    Local OLEnemyPawn Enemy;

    C =Location;
    P =Rotation;
    ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', Enemy)
    {
        if(Enemy !=None)
        {
            E =Enemy.Location;
            F =Enemy.Rotation;
            break;
        }
        else
        {   return;}
    }

    SetLocation(E);
    SetRotation(F); 
    ForEach WorldInfo.AllPawns(Class'OLEnemyPawn', Enemy){
        Enemy.SetCollision(false, false,false);
        Enemy.SetLocation(C);
        Enemy.SetRotation(p);
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
    NoHide(ExPoseEnemy, bSee);
    if(!IsTimerActive('BackSC'))
    {
        SetTimer(UnExpose, false, 'BackSC');
    }
}
Function BackSC()
{
    ClearTimer('SeeLoop');
    NoHide(ExPoseEnemy, !bSee);
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

function bool InRange(Vector A, Vector B, float Range)
{
    return VSize(A-B) <=Range;
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

Function SetEnemySpeed(OLEnemyPawn P, Float Patrol =120, Float Investigate =150, Float Chase =325, float DarkPatrol =-1, float DarkInvestigate =-1, float DarkChase =-1)
{        
    Local int I;

    for(I=0; I<3; I++)
    {
        if(DarkPatrol ==-1)
        {
            DarkPatrol =Patrol;
        }
        else if(DarkInvestigate ==-1)
        {
            DarkInvestigate =Investigate;
        }
        else if(DarkChase ==-1)
        {
            DarkChase =Chase;
        }
    }
    P.NormalSpeedValues.PatrolSpeed=Patrol;
    P.NormalSpeedValues.InvestigateSpeed=Investigate;
    P.NormalSpeedValues.ChaseSpeed=Chase;
    P.DarknessSpeedValues.PatrolSpeed=DarkPatrol;
    P.DarknessSpeedValues.InvestigateSpeed=DarkInvestigate;
    P.DarknessSpeedValues.ChaseSpeed=DarkChase;
}

Exec Function SetGameSpeed(Float Speed=1) {
    WorldInfo.Game.SetGameSpeed(Speed);
}

Function SetBrightness(float B=0.8) 
{
    Controller.FXManager.CurrentUberPostEffect.GrainBrightness = B;
}

Function PlayerAnimRate(Float Rate=1) 
{
    Mesh.GlobalAnimRateScale=Rate;
}

Function EnemyAnimRate(OLEnemyPawn P, Float Rate=1)
{
    P.Mesh.GlobalAnimRateScale=Rate;
}

Function EnemyFastDoor(OLEnemyPawn P, float Multiplier =1.5)
{
    if((P.Bot.bOpeningDoor && !P.ISA('OLEnemyNanoCloud') && P.Bot.ActiveDoor.bDontBreak && !P.Bot.ActiveDoor.bAlwaysBreak) ^^ (P.ISA('OLEnemyNanoCloud') && P.Bot.bOpeningDoor))
    {
        EnemyAnimRate(P, Multiplier);
    }
    else
    {
        EnemyAnimRate(P, 1);
    }
}

Exec Function Kill(Optional OLEnemyPawn P) 
{
    local OLEnemyPawn E;
    if(P ==None)
    {
        ForEach DynamicActors(Class'OLEnemyPawn', E)
        {
            if(E.Bot !=None)
            {   E.Bot.Destroy();}
            E.Destroy();
        }
    }
    else
    {
        if(P.Bot !=None)
        {   P.Bot.Destroy();}
        P.Destroy();
    }
}

// VisionAndHearing Anfang
Function SetEnemyVisionAndHearing(OLEnemyPawn E, EPHero.EnemyVisionType Preset, float Hearing =3000)
{
    switch(Preset)
    {
        case EVT_Normal:
            E.LightAwareVisionParameters.CloseDistance=200;
            E.LightAwareVisionParameters.NarrowCone.Distance=5000;
            E.LightAwareVisionParameters.NarrowCone.PeekingDistance=500;
            E.LightAwareVisionParameters.NarrowCone.HorizontalAngle=30;
            E.LightAwareVisionParameters.NarrowCone.VerticalAngle=30;
            E.LightAwareVisionParameters.WideCone.Distance=800;
            E.LightAwareVisionParameters.WideCone.PeekingDistance=200;
            E.LightAwareVisionParameters.WideCone.HorizontalAngle=70;
            E.LightAwareVisionParameters.WideCone.VerticalAngle=50;
            E.LightAwareVisionParameters.WideConeReactionTime=1.0;
            E.LightAwareVisionParameters.LoseTargetTime=1.5;
            E.LightAwareVisionParameters.CrouchMultiplier=0.5;
            E.NightvisionAwareVisionParameters.CloseDistance=200;
            E.NightvisionAwareVisionParameters.NarrowCone.Distance=5000;
            E.NightvisionAwareVisionParameters.NarrowCone.PeekingDistance=500;
            E.NightvisionAwareVisionParameters.NarrowCone.HorizontalAngle=30;
            E.NightvisionAwareVisionParameters.NarrowCone.VerticalAngle=30;
            E.NightvisionAwareVisionParameters.WideCone.Distance=800;
            E.NightvisionAwareVisionParameters.WideCone.PeekingDistance=200;
            E.NightvisionAwareVisionParameters.WideCone.HorizontalAngle=70;
            E.NightvisionAwareVisionParameters.WideCone.VerticalAngle=45;
            E.NightvisionAwareVisionParameters.WideConeReactionTime=2.0;
            E.NightvisionAwareVisionParameters.LoseTargetTime=1.5;
            E.NightvisionAwareVisionParameters.CrouchMultiplier=0.5;
            E.DarkAwareVisionParameters.CloseDistance=200;
            E.DarkAwareVisionParameters.NarrowCone.Distance=5000;
            E.DarkAwareVisionParameters.NarrowCone.PeekingDistance=500;
            E.DarkAwareVisionParameters.NarrowCone.HorizontalAngle=30;
            E.DarkAwareVisionParameters.NarrowCone.VerticalAngle=30;
            E.DarkAwareVisionParameters.WideCone.Distance=800;
            E.DarkAwareVisionParameters.WideCone.PeekingDistance=200;
            E.DarkAwareVisionParameters.WideCone.HorizontalAngle=70;
            E.DarkAwareVisionParameters.WideCone.VerticalAngle=45;
            E.DarkAwareVisionParameters.WideConeReactionTime=2.0;
            E.DarkAwareVisionParameters.LoseTargetTime=1.5;
            E.DarkAwareVisionParameters.CrouchMultiplier=0.5;
            E.LightUnAwareVisionParameters.CloseDistance=200;
            E.LightUnAwareVisionParameters.NarrowCone.Distance=5000;
            E.LightUnAwareVisionParameters.NarrowCone.PeekingDistance=500;
            E.LightUnAwareVisionParameters.NarrowCone.HorizontalAngle=30;
            E.LightUnAwareVisionParameters.NarrowCone.VerticalAngle=30;
            E.LightUnAwareVisionParameters.WideCone.Distance=800;
            E.LightUnAwareVisionParameters.WideCone.PeekingDistance=200;
            E.LightUnAwareVisionParameters.WideCone.HorizontalAngle=70;
            E.LightUnAwareVisionParameters.WideCone.VerticalAngle=45;
            E.LightUnAwareVisionParameters.WideConeReactionTime=2.0;
            E.LightUnAwareVisionParameters.LoseTargetTime=1.5;
            E.LightUnAwareVisionParameters.CrouchMultiplier=0.5;
            E.NightvisionUnAwareVisionParameters.CloseDistance=200;
            E.NightvisionUnAwareVisionParameters.NarrowCone.Distance=400;
            E.NightvisionUnAwareVisionParameters.NarrowCone.PeekingDistance=200;
            E.NightvisionUnAwareVisionParameters.NarrowCone.HorizontalAngle=20;
            E.NightvisionUnAwareVisionParameters.NarrowCone.VerticalAngle=60;
            E.NightvisionUnAwareVisionParameters.WideCone.Distance=500;
            E.NightvisionUnAwareVisionParameters.WideCone.PeekingDistance=200;
            E.NightvisionUnAwareVisionParameters.WideCone.HorizontalAngle=30;
            E.NightvisionUnAwareVisionParameters.WideCone.VerticalAngle=60;
            E.NightvisionUnAwareVisionParameters.WideConeReactionTime=3.0;
            E.NightvisionUnAwareVisionParameters.LoseTargetTime=1.0;
            E.NightvisionUnAwareVisionParameters.CrouchMultiplier=0.5;
            E.DarkUnAwareVisionParameters.CloseDistance=200;
            E.DarkUnAwareVisionParameters.NarrowCone.Distance=400;
            E.DarkUnAwareVisionParameters.NarrowCone.PeekingDistance=200;
            E.DarkUnAwareVisionParameters.NarrowCone.HorizontalAngle=20;
            E.DarkUnAwareVisionParameters.NarrowCone.VerticalAngle=60;
            E.DarkUnAwareVisionParameters.WideCone.Distance=500;
            E.DarkUnAwareVisionParameters.WideCone.PeekingDistance=200;
            E.DarkUnAwareVisionParameters.WideCone.HorizontalAngle=30;
            E.DarkUnAwareVisionParameters.WideCone.VerticalAngle=60;
            E.DarkUnAwareVisionParameters.WideConeReactionTime=3.0;
            E.DarkUnAwareVisionParameters.LoseTargetTime=1.0;
            E.DarkUnAwareVisionParameters.CrouchMultiplier=0.5;
            break;
        case EVT_EPDefault:
            E.LightAwareVisionParameters.CloseDistance=200;
            E.LightAwareVisionParameters.NarrowCone.Distance=5000;
            E.LightAwareVisionParameters.NarrowCone.PeekingDistance=500;
            E.LightAwareVisionParameters.NarrowCone.HorizontalAngle=90;
            E.LightAwareVisionParameters.NarrowCone.VerticalAngle=45;
            E.LightAwareVisionParameters.WideCone.Distance=800;
            E.LightAwareVisionParameters.WideCone.PeekingDistance=200;
            E.LightAwareVisionParameters.WideCone.HorizontalAngle=179;
            E.LightAwareVisionParameters.WideCone.VerticalAngle=45;
            E.LightAwareVisionParameters.WideConeReactionTime=0.0;
            E.LightAwareVisionParameters.LoseTargetTime=10.0;
            E.LightAwareVisionParameters.CrouchMultiplier=0.1;
            E.NightvisionAwareVisionParameters.CloseDistance=200;
            E.NightvisionAwareVisionParameters.NarrowCone.Distance=5000;
            E.NightvisionAwareVisionParameters.NarrowCone.PeekingDistance=500;
            E.NightvisionAwareVisionParameters.NarrowCone.HorizontalAngle=90;
            E.NightvisionAwareVisionParameters.NarrowCone.VerticalAngle=45;
            E.NightvisionAwareVisionParameters.WideCone.Distance=800;
            E.NightvisionAwareVisionParameters.WideCone.PeekingDistance=200;
            E.NightvisionAwareVisionParameters.WideCone.HorizontalAngle=179;
            E.NightvisionAwareVisionParameters.WideCone.VerticalAngle=45;
            E.NightvisionAwareVisionParameters.WideConeReactionTime=0.0;
            E.NightvisionAwareVisionParameters.LoseTargetTime=10.0;
            E.NightvisionAwareVisionParameters.CrouchMultiplier=0.1;
            E.DarkAwareVisionParameters.CloseDistance=200;
            E.DarkAwareVisionParameters.NarrowCone.Distance=5000;
            E.DarkAwareVisionParameters.NarrowCone.PeekingDistance=500;
            E.DarkAwareVisionParameters.NarrowCone.HorizontalAngle=90;
            E.DarkAwareVisionParameters.NarrowCone.VerticalAngle=45;
            E.DarkAwareVisionParameters.WideCone.Distance=800;
            E.DarkAwareVisionParameters.WideCone.PeekingDistance=200;
            E.DarkAwareVisionParameters.WideCone.HorizontalAngle=179;
            E.DarkAwareVisionParameters.WideCone.VerticalAngle=45;
            E.DarkAwareVisionParameters.WideConeReactionTime=0.0;
            E.DarkAwareVisionParameters.LoseTargetTime=10.0;
            E.DarkAwareVisionParameters.CrouchMultiplier=0.1;
            E.LightUnAwareVisionParameters.CloseDistance=200;
            E.LightUnAwareVisionParameters.NarrowCone.Distance=5000;
            E.LightUnAwareVisionParameters.NarrowCone.PeekingDistance=500;
            E.LightUnAwareVisionParameters.NarrowCone.HorizontalAngle=90;
            E.LightUnAwareVisionParameters.NarrowCone.VerticalAngle=45;
            E.LightUnAwareVisionParameters.WideCone.Distance=800;
            E.LightUnAwareVisionParameters.WideCone.PeekingDistance=200;
            E.LightUnAwareVisionParameters.WideCone.HorizontalAngle=179;
            E.LightUnAwareVisionParameters.WideCone.VerticalAngle=45;
            E.LightUnAwareVisionParameters.WideConeReactionTime=0.0;
            E.LightUnAwareVisionParameters.LoseTargetTime=10.0;
            E.LightUnAwareVisionParameters.CrouchMultiplier=0.1;
            E.NightvisionUnAwareVisionParameters.CloseDistance=200;
            E.NightvisionUnAwareVisionParameters.NarrowCone.Distance=5000;
            E.NightvisionUnAwareVisionParameters.NarrowCone.PeekingDistance=500;
            E.NightvisionUnAwareVisionParameters.NarrowCone.HorizontalAngle=90;
            E.NightvisionUnAwareVisionParameters.NarrowCone.VerticalAngle=45;
            E.NightvisionUnAwareVisionParameters.WideCone.Distance=800;
            E.NightvisionUnAwareVisionParameters.WideCone.PeekingDistance=200;
            E.NightvisionUnAwareVisionParameters.WideCone.HorizontalAngle=179;
            E.NightvisionUnAwareVisionParameters.WideCone.VerticalAngle=45;
            E.NightvisionUnAwareVisionParameters.WideConeReactionTime=0.0;
            E.NightvisionUnAwareVisionParameters.LoseTargetTime=10.0;
            E.NightvisionUnAwareVisionParameters.CrouchMultiplier=0.1;
            E.DarkUnAwareVisionParameters.CloseDistance=200;
            E.DarkUnAwareVisionParameters.NarrowCone.Distance=5000;
            E.DarkUnAwareVisionParameters.NarrowCone.PeekingDistance=500;
            E.DarkUnAwareVisionParameters.NarrowCone.HorizontalAngle=90;
            E.DarkUnAwareVisionParameters.NarrowCone.VerticalAngle=45;
            E.DarkUnAwareVisionParameters.WideCone.Distance=800;
            E.DarkUnAwareVisionParameters.WideCone.PeekingDistance=200;
            E.DarkUnAwareVisionParameters.WideCone.HorizontalAngle=179;
            E.DarkUnAwareVisionParameters.WideCone.VerticalAngle=45;
            E.DarkUnAwareVisionParameters.WideConeReactionTime=0.0;
            E.DarkUnAwareVisionParameters.LoseTargetTime=10.0;
            E.DarkUnAwareVisionParameters.CrouchMultiplier=0.1;
            break;
        case EVT_Trippled:
            E.LightAwareVisionParameters.CloseDistance=600;
            E.LightAwareVisionParameters.NarrowCone.Distance=115000;
            E.LightAwareVisionParameters.NarrowCone.PeekingDistance=1500;
            E.LightAwareVisionParameters.NarrowCone.HorizontalAngle=90;
            E.LightAwareVisionParameters.NarrowCone.VerticalAngle=90;
            E.LightAwareVisionParameters.WideCone.Distance=2400;
            E.LightAwareVisionParameters.WideCone.PeekingDistance=600;
            E.LightAwareVisionParameters.WideCone.HorizontalAngle=210;
            E.LightAwareVisionParameters.WideCone.VerticalAngle=135;
            E.LightAwareVisionParameters.WideConeReactionTime=6.0;
            E.LightAwareVisionParameters.LoseTargetTime=4.5;
            E.LightAwareVisionParameters.CrouchMultiplier=1.5;
            E.NightvisionAwareVisionParameters.CloseDistance=600;
            E.NightvisionAwareVisionParameters.NarrowCone.Distance=115000;
            E.NightvisionAwareVisionParameters.NarrowCone.PeekingDistance=1500;
            E.NightvisionAwareVisionParameters.NarrowCone.HorizontalAngle=90;
            E.NightvisionAwareVisionParameters.NarrowCone.VerticalAngle=90;
            E.NightvisionAwareVisionParameters.WideCone.Distance=2400;
            E.NightvisionAwareVisionParameters.WideCone.PeekingDistance=600;
            E.NightvisionAwareVisionParameters.WideCone.HorizontalAngle=210;
            E.NightvisionAwareVisionParameters.WideCone.VerticalAngle=135;
            E.NightvisionAwareVisionParameters.WideConeReactionTime=6.0;
            E.NightvisionAwareVisionParameters.LoseTargetTime=4.5;
            E.NightvisionAwareVisionParameters.CrouchMultiplier=1.5;
            E.DarkAwareVisionParameters.CloseDistance=600;
            E.DarkAwareVisionParameters.NarrowCone.Distance=115000;
            E.DarkAwareVisionParameters.NarrowCone.PeekingDistance=1500;
            E.DarkAwareVisionParameters.NarrowCone.HorizontalAngle=90;
            E.DarkAwareVisionParameters.NarrowCone.VerticalAngle=90;
            E.DarkAwareVisionParameters.WideCone.Distance=2400;
            E.DarkAwareVisionParameters.WideCone.PeekingDistance=600;
            E.DarkAwareVisionParameters.WideCone.HorizontalAngle=210;
            E.DarkAwareVisionParameters.WideCone.VerticalAngle=135;
            E.DarkAwareVisionParameters.WideConeReactionTime=6.0;
            E.DarkAwareVisionParameters.LoseTargetTime=4.5;
            E.DarkAwareVisionParameters.CrouchMultiplier=1.5;
            E.LightUnAwareVisionParameters.CloseDistance=600;
            E.LightUnAwareVisionParameters.NarrowCone.Distance=115000;
            E.LightUnAwareVisionParameters.NarrowCone.PeekingDistance=1500;
            E.LightUnAwareVisionParameters.NarrowCone.HorizontalAngle=90;
            E.LightUnAwareVisionParameters.NarrowCone.VerticalAngle=90;
            E.LightUnAwareVisionParameters.WideCone.Distance=2400;
            E.LightUnAwareVisionParameters.WideCone.PeekingDistance=600;
            E.LightUnAwareVisionParameters.WideCone.HorizontalAngle=210;
            E.LightUnAwareVisionParameters.WideCone.VerticalAngle=135;
            E.LightUnAwareVisionParameters.WideConeReactionTime=6.0;
            E.LightUnAwareVisionParameters.LoseTargetTime=4.5;
            E.LightUnAwareVisionParameters.CrouchMultiplier=1.5;
            E.NightvisionUnAwareVisionParameters.CloseDistance=1800;
            E.NightvisionUnAwareVisionParameters.NarrowCone.Distance=11800;
            E.NightvisionUnAwareVisionParameters.NarrowCone.PeekingDistance=1800;
            E.NightvisionUnAwareVisionParameters.NarrowCone.HorizontalAngle=180;
            E.NightvisionUnAwareVisionParameters.NarrowCone.VerticalAngle=180;
            E.NightvisionUnAwareVisionParameters.WideCone.Distance=1500;
            E.NightvisionUnAwareVisionParameters.WideCone.PeekingDistance=1800;
            E.NightvisionUnAwareVisionParameters.WideCone.HorizontalAngle=90;
            E.NightvisionUnAwareVisionParameters.WideCone.VerticalAngle=180;
            E.NightvisionUnAwareVisionParameters.WideConeReactionTime=9.0;
            E.NightvisionUnAwareVisionParameters.LoseTargetTime=3.0;
            E.NightvisionUnAwareVisionParameters.CrouchMultiplier=1.5;
            E.DarkUnAwareVisionParameters.CloseDistance=1800;
            E.DarkUnAwareVisionParameters.NarrowCone.Distance=11800;
            E.DarkUnAwareVisionParameters.NarrowCone.PeekingDistance=1800;
            E.DarkUnAwareVisionParameters.NarrowCone.HorizontalAngle=180;
            E.DarkUnAwareVisionParameters.NarrowCone.VerticalAngle=180;
            E.DarkUnAwareVisionParameters.WideCone.Distance=1500;
            E.DarkUnAwareVisionParameters.WideCone.PeekingDistance=1800;
            E.DarkUnAwareVisionParameters.WideCone.HorizontalAngle=90;
            E.DarkUnAwareVisionParameters.WideCone.VerticalAngle=180;
            E.DarkUnAwareVisionParameters.WideConeReactionTime=9.0;
            E.DarkUnAwareVisionParameters.LoseTargetTime=3.0;
            E.DarkUnAwareVisionParameters.CrouchMultiplier=1.5;
            break;
        case EVT_EPEule:
            E.LightAwareVisionParameters.CloseDistance=600;
            E.LightAwareVisionParameters.NarrowCone.Distance=20000;
            E.LightAwareVisionParameters.NarrowCone.PeekingDistance=5000;
            E.LightAwareVisionParameters.NarrowCone.HorizontalAngle=180;
            E.LightAwareVisionParameters.NarrowCone.VerticalAngle=90;
            E.LightAwareVisionParameters.WideCone.Distance=19000;
            E.LightAwareVisionParameters.WideCone.PeekingDistance=4900;
            E.LightAwareVisionParameters.WideCone.HorizontalAngle=179;
            E.LightAwareVisionParameters.WideCone.VerticalAngle=89;
            E.LightAwareVisionParameters.WideConeReactionTime=0.1;
            E.LightAwareVisionParameters.LoseTargetTime=4.5;
            E.LightAwareVisionParameters.CrouchMultiplier=1.0;
            E.NightvisionAwareVisionParameters.CloseDistance=600;
            E.NightvisionAwareVisionParameters.NarrowCone.Distance=20000;
            E.NightvisionAwareVisionParameters.NarrowCone.PeekingDistance=5000;
            E.NightvisionAwareVisionParameters.NarrowCone.HorizontalAngle=180;
            E.NightvisionAwareVisionParameters.NarrowCone.VerticalAngle=90;
            E.NightvisionAwareVisionParameters.WideCone.Distance=19000;
            E.NightvisionAwareVisionParameters.WideCone.PeekingDistance=4900;
            E.NightvisionAwareVisionParameters.WideCone.HorizontalAngle=179;
            E.NightvisionAwareVisionParameters.WideCone.VerticalAngle=89;
            E.NightvisionAwareVisionParameters.WideConeReactionTime=0.1;
            E.NightvisionAwareVisionParameters.LoseTargetTime=4.5;
            E.NightvisionAwareVisionParameters.CrouchMultiplier=1.0;
            E.DarkAwareVisionParameters.CloseDistance=600;
            E.DarkAwareVisionParameters.NarrowCone.Distance=20000;
            E.DarkAwareVisionParameters.NarrowCone.PeekingDistance=5000;
            E.DarkAwareVisionParameters.NarrowCone.HorizontalAngle=180;
            E.DarkAwareVisionParameters.NarrowCone.VerticalAngle=90;
            E.DarkAwareVisionParameters.WideCone.Distance=19000;
            E.DarkAwareVisionParameters.WideCone.PeekingDistance=4900;
            E.DarkAwareVisionParameters.WideCone.HorizontalAngle=179;
            E.DarkAwareVisionParameters.WideCone.VerticalAngle=89;
            E.DarkAwareVisionParameters.WideConeReactionTime=0.1;
            E.DarkAwareVisionParameters.LoseTargetTime=4.5;
            E.DarkAwareVisionParameters.CrouchMultiplier=1.0;
            E.LightUnAwareVisionParameters.CloseDistance=600;
            E.LightUnAwareVisionParameters.NarrowCone.Distance=20000;
            E.LightUnAwareVisionParameters.NarrowCone.PeekingDistance=5000;
            E.LightUnAwareVisionParameters.NarrowCone.HorizontalAngle=180;
            E.LightUnAwareVisionParameters.NarrowCone.VerticalAngle=90;
            E.LightUnAwareVisionParameters.WideCone.Distance=19000;
            E.LightUnAwareVisionParameters.WideCone.PeekingDistance=4900;
            E.LightUnAwareVisionParameters.WideCone.HorizontalAngle=179;
            E.LightUnAwareVisionParameters.WideCone.VerticalAngle=89;
            E.LightUnAwareVisionParameters.WideConeReactionTime=0.1;
            E.LightUnAwareVisionParameters.LoseTargetTime=4.5;
            E.LightUnAwareVisionParameters.CrouchMultiplier=1.0;
            E.NightvisionUnAwareVisionParameters.CloseDistance=600;
            E.NightvisionUnAwareVisionParameters.NarrowCone.Distance=20000;
            E.NightvisionUnAwareVisionParameters.NarrowCone.PeekingDistance=5000;
            E.NightvisionUnAwareVisionParameters.NarrowCone.HorizontalAngle=180;
            E.NightvisionUnAwareVisionParameters.NarrowCone.VerticalAngle=90;
            E.NightvisionUnAwareVisionParameters.WideCone.Distance=19000;
            E.NightvisionUnAwareVisionParameters.WideCone.PeekingDistance=4900;
            E.NightvisionUnAwareVisionParameters.WideCone.HorizontalAngle=179;
            E.NightvisionUnAwareVisionParameters.WideCone.VerticalAngle=89;
            E.NightvisionUnAwareVisionParameters.WideConeReactionTime=0.1;
            E.NightvisionUnAwareVisionParameters.LoseTargetTime=4.5;
            E.NightvisionUnAwareVisionParameters.CrouchMultiplier=1.0;
            E.DarkUnAwareVisionParameters.CloseDistance=600;
            E.DarkUnAwareVisionParameters.NarrowCone.Distance=20000;
            E.DarkUnAwareVisionParameters.NarrowCone.PeekingDistance=5000;
            E.DarkUnAwareVisionParameters.NarrowCone.HorizontalAngle=180;
            E.DarkUnAwareVisionParameters.NarrowCone.VerticalAngle=90;
            E.DarkUnAwareVisionParameters.WideCone.Distance=19000;
            E.DarkUnAwareVisionParameters.WideCone.PeekingDistance=4900;
            E.DarkUnAwareVisionParameters.WideCone.HorizontalAngle=189;
            E.DarkUnAwareVisionParameters.WideCone.VerticalAngle=89;
            E.DarkUnAwareVisionParameters.WideConeReactionTime=0.1;
            E.DarkUnAwareVisionParameters.LoseTargetTime=4.5;
            E.DarkUnAwareVisionParameters.CrouchMultiplier=1.0;
            break;
        case EVT_EPAlt:
            E.LightAwareVisionParameters.CloseDistance=120;
            E.LightAwareVisionParameters.NarrowCone.Distance=5000;
            E.LightAwareVisionParameters.NarrowCone.PeekingDistance=500;
            E.LightAwareVisionParameters.NarrowCone.HorizontalAngle=30;
            E.LightAwareVisionParameters.NarrowCone.VerticalAngle=30;
            E.LightAwareVisionParameters.WideCone.Distance=800;
            E.LightAwareVisionParameters.WideCone.PeekingDistance=200;
            E.LightAwareVisionParameters.WideCone.HorizontalAngle=70;
            E.LightAwareVisionParameters.WideCone.VerticalAngle=50;
            E.LightAwareVisionParameters.WideConeReactionTime=0.0;
            E.LightAwareVisionParameters.LoseTargetTime=3.0;
            E.LightAwareVisionParameters.CrouchMultiplier=1.0;
            E.NightvisionAwareVisionParameters.CloseDistance=200;
            E.NightvisionAwareVisionParameters.NarrowCone.Distance=5000;
            E.NightvisionAwareVisionParameters.NarrowCone.PeekingDistance=500;
            E.NightvisionAwareVisionParameters.NarrowCone.HorizontalAngle=30;
            E.NightvisionAwareVisionParameters.NarrowCone.VerticalAngle=30;
            E.NightvisionAwareVisionParameters.WideCone.Distance=800;
            E.NightvisionAwareVisionParameters.WideCone.PeekingDistance=200;
            E.NightvisionAwareVisionParameters.WideCone.HorizontalAngle=70;
            E.NightvisionAwareVisionParameters.WideCone.VerticalAngle=50;
            E.NightvisionAwareVisionParameters.WideConeReactionTime=0.0;
            E.NightvisionAwareVisionParameters.LoseTargetTime=3.0;
            E.NightvisionAwareVisionParameters.CrouchMultiplier=1.0;
            E.DarkAwareVisionParameters.CloseDistance=200;
            E.DarkAwareVisionParameters.NarrowCone.Distance=5000;
            E.DarkAwareVisionParameters.NarrowCone.PeekingDistance=500;
            E.DarkAwareVisionParameters.NarrowCone.HorizontalAngle=30;
            E.DarkAwareVisionParameters.NarrowCone.VerticalAngle=30;
            E.DarkAwareVisionParameters.WideCone.Distance=800;
            E.DarkAwareVisionParameters.WideCone.PeekingDistance=200;
            E.DarkAwareVisionParameters.WideCone.HorizontalAngle=70;
            E.DarkAwareVisionParameters.WideCone.VerticalAngle=50;
            E.DarkAwareVisionParameters.WideConeReactionTime=0.0;
            E.DarkAwareVisionParameters.LoseTargetTime=3.0;
            E.DarkAwareVisionParameters.CrouchMultiplier=1.0;
            E.LightUnAwareVisionParameters.CloseDistance=200;
            E.LightUnAwareVisionParameters.NarrowCone.Distance=5000;
            E.LightUnAwareVisionParameters.NarrowCone.PeekingDistance=500;
            E.LightUnAwareVisionParameters.NarrowCone.HorizontalAngle=30;
            E.LightUnAwareVisionParameters.NarrowCone.VerticalAngle=30;
            E.LightUnAwareVisionParameters.WideCone.Distance=800;
            E.LightUnAwareVisionParameters.WideCone.PeekingDistance=200;
            E.LightUnAwareVisionParameters.WideCone.HorizontalAngle=70;
            E.LightUnAwareVisionParameters.WideCone.VerticalAngle=45;
            E.LightUnAwareVisionParameters.WideConeReactionTime=0.0;
            E.LightUnAwareVisionParameters.LoseTargetTime=3.0;
            E.LightUnAwareVisionParameters.CrouchMultiplier=1.0;
            E.NightvisionUnAwareVisionParameters.CloseDistance=200;
            E.NightvisionUnAwareVisionParameters.NarrowCone.Distance=5000;
            E.NightvisionUnAwareVisionParameters.NarrowCone.PeekingDistance=500;
            E.NightvisionUnAwareVisionParameters.NarrowCone.HorizontalAngle=30;
            E.NightvisionUnAwareVisionParameters.NarrowCone.VerticalAngle=30;
            E.NightvisionUnAwareVisionParameters.WideCone.Distance=800;
            E.NightvisionUnAwareVisionParameters.WideCone.PeekingDistance=200;
            E.NightvisionUnAwareVisionParameters.WideCone.HorizontalAngle=70;
            E.NightvisionUnAwareVisionParameters.WideCone.VerticalAngle=45;
            E.NightvisionUnAwareVisionParameters.WideConeReactionTime=0.0;
            E.NightvisionUnAwareVisionParameters.LoseTargetTime=3.0;
            E.NightvisionUnAwareVisionParameters.CrouchMultiplier=1.0;
            E.DarkUnAwareVisionParameters.CloseDistance=200;
            E.DarkUnAwareVisionParameters.NarrowCone.Distance=5000;
            E.DarkUnAwareVisionParameters.NarrowCone.PeekingDistance=500;
            E.DarkUnAwareVisionParameters.NarrowCone.HorizontalAngle=30;
            E.DarkUnAwareVisionParameters.NarrowCone.VerticalAngle=30;
            E.DarkUnAwareVisionParameters.WideCone.Distance=800;
            E.DarkUnAwareVisionParameters.WideCone.PeekingDistance=200;
            E.DarkUnAwareVisionParameters.WideCone.HorizontalAngle=70;
            E.DarkUnAwareVisionParameters.WideCone.VerticalAngle=45;
            E.DarkUnAwareVisionParameters.WideConeReactionTime=0.0;
            E.DarkUnAwareVisionParameters.LoseTargetTime=3.0;
            E.DarkUnAwareVisionParameters.CrouchMultiplier=1.0;
            break;            
    }
    E.HearingThreshold=Hearing;
}
// VisionAndHearing Ende

Function SetEnemyAttackAndDoor(OLEnemyPawn P, float Range =170.0, float SQRange =1000, float Grab =0.99, float PushKB =15, float Delay =0.01, float Normal =101, float Throw =101, float Vault =101, float Door =101, int Bashes =0, float PathMultiplier =3)
{
    P.AttackRange=Range;
    P.AttackSqueezeRange=SQRange;
    P.AttackGrabChance=Grab;
    P.AttackPushKnockbackPower=PushKB;
    P.AttackNormalRecovery=Delay;
    P.AttackNormalDamage=Normal;
    P.AttackThrowDamage=Throw;
    P.DoorBashDamage=Door;
    P.VaultDamage=Vault;
    P.NumOfDoorBashLoops=Bashes;
    P.DoorClosedPathMultiplier=PathMultiplier;
    P.AttackQuickDistanceThreshold=Range-10;
}

Function SetEnemyInvestigation(OLEnemyPawn P, int InvPoints =8, float Min =200, float Max =600, float Angle =60, float PathDist =1200, float NPrio =1, float LockerPrio =10, float LockerOcPrio =10, float BedPrio=10, float BedOcPrio =10, float findProb =0.99, float NWait =1, float CWait =1, float BedAlternate =0, bool Beds =true, bool Lockers =true, bool PrefPaths =true)
{
    P.InvestigationNumPointsGenerated=InvPoints;
    P.InvestigationMinRadius=Min;
    P.InvestigationMaxRadius=Max;
    P.InvestigationMaxPathDistance=PathDist;
    P.InvestigationFirstPointAngle=Angle;
    P.InvestigationNormalWeight=NPrio;
    P.InvestigationLockerWeight=LockerPrio;
    P.InvestigationLockerOccupiedWeight=LockerOcPrio;
    P.InvestigationBedWeight=BedPrio;
    P.InvestigationBedOccupiedWeight=BedOcPrio;
    P.InvestigationFindHiddenPlayerProbability=findProb;
    P.WaitLeaveNormalMultiplier=NWait;
    P.WaitLeaveChaseMultiplier=CWait;
    P.bInvestigateLockers=Lockers;
    P.bInvestigateBeds=Beds;
    P.bUsePreferredPaths=PrefPaths;
    P.InvestigateBedAlternateChance=BedAlternate;
}

Function SetStaticEnemyValues(OLEnemyPawn P)
{
    P.MoveReactionTime =0.7;
    P.UnstuckCheckTime=0.33;
    P.LookAheadDistance=100;
    P.LookAheadUpdateTime=0.33;
    p.AttackSqueezeCycleTime=5.0;
    P.DoorBashKnockbackPower=30;
    P.VaultKnockbackPower=30;
    P.AttackQuickAngleThreshold=45;
    P.AttackQuickSpeedThreshold=150;
    P.bAttackUseQuickAttack=true;
}

Function NoHide(OLEnemyPawn P, bool Enable =true)
{
    P.Bot.SightComponent.bAlwaysSeeTarget=enable;
    P.Bot.SightComponent.bSawPlayerEnterHidingSpot = enable;
    P.Bot.SightComponent.bSawPlayerEnterBed = enable;
    P.Bot.SightComponent.bSawPlayerGoUnder = enable;
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
    if(LocomotionMode ==LM_Locker || LocomotionMode ==LM_Cinematic || LocomotionMode ==LM_Bed)
    {
        RespawnHero();
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

Function TP(Float X, Float Y, Float Z, Float R1, Float R2, Float R3){
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
        Controller.CopyToClipBoard("Vect(" $Location.X $"," @Location.Y $"," @Location.Z $") || Rot(" $Rotation.Pitch $"," @Rotation.Yaw $"," @Rotation.Roll $")");
    }
}

Event RespawnHero()
{
    Local EPPointLight EPL;
    Super.RespawnHero();
    if(Controller.bFreeCamOn)
    {
        Controller.ToggleFreeCam();
    }
    if(EPHud(Controller.Hud).ToggleHUD)
    {
        Controller.ToggleConsole(false);
    }
    ForEach AllActors(Class'EPPointLight', EPL)
    {
        if(EPL.Tag =='EPA' || EPL.Tag =='Rot' || EPL.Tag =='Gelb')
            {EPL.Destroy();}
    }
}

Function bool ValidCP(name CP)
{
    return CurrentCP ==CP && CurrentCP !=LastCP;
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
    I =0
    LastCP ='Ungueltig'
}