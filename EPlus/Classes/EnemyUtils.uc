class EnemyUtils extends Object;

/* This class tries to replicate/implement  method chaining.
 *   The caller of these functions has to make sure all references are valid.
*/


/* Enum values mend  to be used for setting visionparameters in SetEnemyVisionAndHearing.
 * Except for EVT_Normal and EVT_Trippled, all tags give enemies clear sight in the darkness.
 * EVT_Normal: Default visionparameters ( most likely from OLEnemyPawn).
 * EVT_EPDefault: WB Extreme Plus 2 vision parameters, high viewing angle, not quite 360 degree.
 * EVT_Trippled: all numeric values of the parameters are multiplied by 3.
 * EVT_EPEule: Full 360 degree view.
 * EVT_EPAlt: Extreme Plus 1 vision parameters.
*/
enum EnemyVisionType
{
    EVT_Normal,
    EVT_EPDefault,
    EVT_Trippled,
    EVT_EPEule,
    EVT_EPAlt
};

var private OLEnemyPawn Enemy;
var private WorldInfo WI;

// Constructor.
static function EnemyUtils init(optional OLEnemyPawn P){
    local EnemyUtils instance;

    instance =new (class'WorldInfo'.static.GetWorldInfo()) class'EnemyUtils';
    instance.WI =WorldInfo(instance.Outer);
    if (P !=none){
        instance.setEnemy(p);
    }
    return instance;
}

// Setter for OLEnemy.
function EnemyUtils setEnemy(OLEnemyPawn P){
    Enemy =P;
    return self;
}

// spawns a random attacking enemy.
function EnemyUtils CreateRandomEnemy(Vector V, Rotator R, name Tag ='EPEnemy', bool CreateWithCollision =true){
    local Array<class<OLEnemyPawn> > E;
    
    E.AddItem(Class'OLEnemySurgeon');
    E.AddItem(Class'OLEnemySoldier');
    E.AddItem(Class'OLEnemyNanoCloud');
    E.AddItem(Class'OLEnemyGroom');
    E.AddItem(Class'OLEnemyGenericPatient');
    E.AddItem(Class'OLEnemyCannibal');
    CreateEnemy(
        E[Rand(E.length)],
        V, R, Tag, CreateWithCollision
    );
    return self;
}

// Spawns an enemy determined by the parameter EnemyClass
function EnemyUtils CreateEnemy(Class<OLEnemyPawn> EnemyClass, Vector V, Rotator R, name Tag ='EPEnemy', bool CreateWithCollision =true){
    local OLBot B;
    
    Enemy =WI.Spawn(EnemyClass,,Tag,V,R,,true);
    Enemy.Modifiers.bShouldAttack =true;
    Enemy.Modifiers.bUseForMusic =true;
    switch(Enemy.Class){
    case class'OLEnemyCannibal':
        Enemy.BehaviorTree = OLBTBehaviorTree'Male_ward_03_LD.02_AI_Behaviors.Surgeon_FullLoop_BT';
        EquippWeapon(Weapon_CannibalDrill);
        break;
    case class'OLEnemyGroom':
        Enemy.Mesh.SetSkeletalMesh(Class'MeshList'.default.GroomMesh);
        break;
    case Class'OLEnemySurgeon':
        Enemy.Mesh.SetSkeletalMesh(class'MeshList'.default.TragerMesh);
        Enemy.BehaviorTree = OLBTBehaviorTree'Male_ward_03_LD.02_AI_Behaviors.Surgeon_FullLoop_BT';
        EquippWeapon(Weapon_BoneShear);
        break;
    case class'OLEnemyGenericPatient':
        Enemy.Mesh.SetSkeletalMesh(class'MeshList'.default.DefaultPatientMesh);
        Enemy.BehaviorTree = OLBTBehaviorTree'Prison_01-LD.02_AI_Behaviors.Generic_FullLoop_BT';
        EquippWeapon(Weapon_None);
    }
    B =Enemy.Spawn(Class'OLBot');
    B.Possess(Enemy, false);
    if (!CreateWithCollision){
        Enemy.SetCollision(false, false, false);
    }
    return self;
}

function EnemyUtils EquippRandomWeapon(){
    local int I;
    for (I =255; I>8 || I ==3; I =Rand(8)){}
    return EquippWeapon(Eweapon(I));
}

function EnemyUtils EquippWeapon(EWeapon W){
    Enemy.Modifiers.WeaponToUse =W;
    Enemy.ApplyModifiers(Enemy.Modifiers);
    return self;
}

// getter for Enemy
function OLEnemyPawn getEnemy(){
    return Enemy;
}
// setter for skeletalMesh
function EnemyUtils setModel(SkeletalMesh sk){
    Enemy.mesh.setSkeletalMesh(sk);
    return self;
}

// Setter for BehaviorTree
function EnemyUtils setBehavior(OLBTBehaviorTree behavior){
    Enemy.BehaviorTree = behavior;
    return self;
}

Function EnemyUtils SetEnemySpeed(Float Patrol =120, Float Investigate =150, Float Chase =325, float DarkPatrol =-1, float DarkInvestigate =-1, float DarkChase =-1){        
    if(DarkPatrol ==-1)
    {
        DarkPatrol =Patrol;
    }
    if(DarkInvestigate ==-1)
    {
        DarkInvestigate =Investigate;
    }
    if(DarkChase ==-1)
    {
        DarkChase =Chase;
    }
    Enemy.NormalSpeedValues.PatrolSpeed=Patrol;
    Enemy.NormalSpeedValues.InvestigateSpeed=Investigate;
    Enemy.NormalSpeedValues.ChaseSpeed=Chase;
    Enemy.DarknessSpeedValues.PatrolSpeed=DarkPatrol;
    Enemy.DarknessSpeedValues.InvestigateSpeed=DarkInvestigate;
    Enemy.DarknessSpeedValues.ChaseSpeed=DarkChase;
    return self;
}

Function EnemyUtils EnemyAnimRate(Float Rate=1){
    Enemy.Mesh.GlobalAnimRateScale=Rate;
    return self;
}

Function EnemyUtils EnemySpeedUp(float Multiplier =1.5, bool Investigate =true)
{
    local bool OpeningDoor, ValidInvestigation;

    ValidInvestigation =Investigate && (Enemy.Specialmove ==SMT_InvestigateBed || Enemy.Specialmove ==SMT_InvestigateLocker);
    OpeningDoor =Enemy.SpecialMove ==SMT_EnterDoorInteraction || Enemy.SpecialMove ==SMT_NanoThroughDoor || (Enemy.Specialmove >87 && Enemy.Specialmove <93);

    if(OpeningDoor || ValidInvestigation)
    {
        EnemyAnimRate(Multiplier);
    }
    else
    {
        EnemyAnimRate(1);
    }
    return self;
}

// VisionAndHearing start
Function EnemyUtils SetEnemyVisionAndHearing(EnemyVisionType Preset, float Hearing =3000)
{
    switch(Preset)
    {
        case EVT_Normal:
            Enemy.LightAwareVisionParameters.CloseDistance=200;
            Enemy.LightAwareVisionParameters.NarrowCone.Distance=5000;
            Enemy.LightAwareVisionParameters.NarrowCone.PeekingDistance=500;
            Enemy.LightAwareVisionParameters.NarrowCone.HorizontalAngle=30;
            Enemy.LightAwareVisionParameters.NarrowCone.VerticalAngle=30;
            Enemy.LightAwareVisionParameters.WideCone.Distance=800;
            Enemy.LightAwareVisionParameters.WideCone.PeekingDistance=200;
            Enemy.LightAwareVisionParameters.WideCone.HorizontalAngle=70;
            Enemy.LightAwareVisionParameters.WideCone.VerticalAngle=50;
            Enemy.LightAwareVisionParameters.WideConeReactionTime=1.0;
            Enemy.LightAwareVisionParameters.LoseTargetTime=1.5;
            Enemy.LightAwareVisionParameters.CrouchMultiplier=0.5;
            Enemy.NightvisionAwareVisionParameters.CloseDistance=200;
            Enemy.NightvisionAwareVisionParameters.NarrowCone.Distance=5000;
            Enemy.NightvisionAwareVisionParameters.NarrowCone.PeekingDistance=500;
            Enemy.NightvisionAwareVisionParameters.NarrowCone.HorizontalAngle=30;
            Enemy.NightvisionAwareVisionParameters.NarrowCone.VerticalAngle=30;
            Enemy.NightvisionAwareVisionParameters.WideCone.Distance=800;
            Enemy.NightvisionAwareVisionParameters.WideCone.PeekingDistance=200;
            Enemy.NightvisionAwareVisionParameters.WideCone.HorizontalAngle=70;
            Enemy.NightvisionAwareVisionParameters.WideCone.VerticalAngle=45;
            Enemy.NightvisionAwareVisionParameters.WideConeReactionTime=2.0;
            Enemy.NightvisionAwareVisionParameters.LoseTargetTime=1.5;
            Enemy.NightvisionAwareVisionParameters.CrouchMultiplier=0.5;
            Enemy.DarkAwareVisionParameters.CloseDistance=200;
            Enemy.DarkAwareVisionParameters.NarrowCone.Distance=5000;
            Enemy.DarkAwareVisionParameters.NarrowCone.PeekingDistance=500;
            Enemy.DarkAwareVisionParameters.NarrowCone.HorizontalAngle=30;
            Enemy.DarkAwareVisionParameters.NarrowCone.VerticalAngle=30;
            Enemy.DarkAwareVisionParameters.WideCone.Distance=800;
            Enemy.DarkAwareVisionParameters.WideCone.PeekingDistance=200;
            Enemy.DarkAwareVisionParameters.WideCone.HorizontalAngle=70;
            Enemy.DarkAwareVisionParameters.WideCone.VerticalAngle=45;
            Enemy.DarkAwareVisionParameters.WideConeReactionTime=2.0;
            Enemy.DarkAwareVisionParameters.LoseTargetTime=1.5;
            Enemy.DarkAwareVisionParameters.CrouchMultiplier=0.5;
            Enemy.LightUnAwareVisionParameters.CloseDistance=200;
            Enemy.LightUnAwareVisionParameters.NarrowCone.Distance=5000;
            Enemy.LightUnAwareVisionParameters.NarrowCone.PeekingDistance=500;
            Enemy.LightUnAwareVisionParameters.NarrowCone.HorizontalAngle=30;
            Enemy.LightUnAwareVisionParameters.NarrowCone.VerticalAngle=30;
            Enemy.LightUnAwareVisionParameters.WideCone.Distance=800;
            Enemy.LightUnAwareVisionParameters.WideCone.PeekingDistance=200;
            Enemy.LightUnAwareVisionParameters.WideCone.HorizontalAngle=70;
            Enemy.LightUnAwareVisionParameters.WideCone.VerticalAngle=45;
            Enemy.LightUnAwareVisionParameters.WideConeReactionTime=2.0;
            Enemy.LightUnAwareVisionParameters.LoseTargetTime=1.5;
            Enemy.LightUnAwareVisionParameters.CrouchMultiplier=0.5;
            Enemy.NightvisionUnAwareVisionParameters.CloseDistance=200;
            Enemy.NightvisionUnAwareVisionParameters.NarrowCone.Distance=400;
            Enemy.NightvisionUnAwareVisionParameters.NarrowCone.PeekingDistance=200;
            Enemy.NightvisionUnAwareVisionParameters.NarrowCone.HorizontalAngle=20;
            Enemy.NightvisionUnAwareVisionParameters.NarrowCone.VerticalAngle=60;
            Enemy.NightvisionUnAwareVisionParameters.WideCone.Distance=500;
            Enemy.NightvisionUnAwareVisionParameters.WideCone.PeekingDistance=200;
            Enemy.NightvisionUnAwareVisionParameters.WideCone.HorizontalAngle=30;
            Enemy.NightvisionUnAwareVisionParameters.WideCone.VerticalAngle=60;
            Enemy.NightvisionUnAwareVisionParameters.WideConeReactionTime=3.0;
            Enemy.NightvisionUnAwareVisionParameters.LoseTargetTime=1.0;
            Enemy.NightvisionUnAwareVisionParameters.CrouchMultiplier=0.5;
            Enemy.DarkUnAwareVisionParameters.CloseDistance=200;
            Enemy.DarkUnAwareVisionParameters.NarrowCone.Distance=400;
            Enemy.DarkUnAwareVisionParameters.NarrowCone.PeekingDistance=200;
            Enemy.DarkUnAwareVisionParameters.NarrowCone.HorizontalAngle=20;
            Enemy.DarkUnAwareVisionParameters.NarrowCone.VerticalAngle=60;
            Enemy.DarkUnAwareVisionParameters.WideCone.Distance=500;
            Enemy.DarkUnAwareVisionParameters.WideCone.PeekingDistance=200;
            Enemy.DarkUnAwareVisionParameters.WideCone.HorizontalAngle=30;
            Enemy.DarkUnAwareVisionParameters.WideCone.VerticalAngle=60;
            Enemy.DarkUnAwareVisionParameters.WideConeReactionTime=3.0;
            Enemy.DarkUnAwareVisionParameters.LoseTargetTime=1.0;
            Enemy.DarkUnAwareVisionParameters.CrouchMultiplier=0.5;
            break;
        case EVT_EPDefault:
            Enemy.LightAwareVisionParameters.CloseDistance=200;
            Enemy.LightAwareVisionParameters.NarrowCone.Distance=5000;
            Enemy.LightAwareVisionParameters.NarrowCone.PeekingDistance=500;
            Enemy.LightAwareVisionParameters.NarrowCone.HorizontalAngle=90;
            Enemy.LightAwareVisionParameters.NarrowCone.VerticalAngle=45;
            Enemy.LightAwareVisionParameters.WideCone.Distance=800;
            Enemy.LightAwareVisionParameters.WideCone.PeekingDistance=200;
            Enemy.LightAwareVisionParameters.WideCone.HorizontalAngle=179;
            Enemy.LightAwareVisionParameters.WideCone.VerticalAngle=45;
            Enemy.LightAwareVisionParameters.WideConeReactionTime=0.0;
            Enemy.LightAwareVisionParameters.LoseTargetTime=10.0;
            Enemy.LightAwareVisionParameters.CrouchMultiplier=0.1;
            Enemy.NightvisionAwareVisionParameters.CloseDistance=200;
            Enemy.NightvisionAwareVisionParameters.NarrowCone.Distance=5000;
            Enemy.NightvisionAwareVisionParameters.NarrowCone.PeekingDistance=500;
            Enemy.NightvisionAwareVisionParameters.NarrowCone.HorizontalAngle=90;
            Enemy.NightvisionAwareVisionParameters.NarrowCone.VerticalAngle=45;
            Enemy.NightvisionAwareVisionParameters.WideCone.Distance=800;
            Enemy.NightvisionAwareVisionParameters.WideCone.PeekingDistance=200;
            Enemy.NightvisionAwareVisionParameters.WideCone.HorizontalAngle=179;
            Enemy.NightvisionAwareVisionParameters.WideCone.VerticalAngle=45;
            Enemy.NightvisionAwareVisionParameters.WideConeReactionTime=0.0;
            Enemy.NightvisionAwareVisionParameters.LoseTargetTime=10.0;
            Enemy.NightvisionAwareVisionParameters.CrouchMultiplier=0.1;
            Enemy.DarkAwareVisionParameters.CloseDistance=200;
            Enemy.DarkAwareVisionParameters.NarrowCone.Distance=5000;
            Enemy.DarkAwareVisionParameters.NarrowCone.PeekingDistance=500;
            Enemy.DarkAwareVisionParameters.NarrowCone.HorizontalAngle=90;
            Enemy.DarkAwareVisionParameters.NarrowCone.VerticalAngle=45;
            Enemy.DarkAwareVisionParameters.WideCone.Distance=800;
            Enemy.DarkAwareVisionParameters.WideCone.PeekingDistance=200;
            Enemy.DarkAwareVisionParameters.WideCone.HorizontalAngle=179;
            Enemy.DarkAwareVisionParameters.WideCone.VerticalAngle=45;
            Enemy.DarkAwareVisionParameters.WideConeReactionTime=0.0;
            Enemy.DarkAwareVisionParameters.LoseTargetTime=10.0;
            Enemy.DarkAwareVisionParameters.CrouchMultiplier=0.1;
            Enemy.LightUnAwareVisionParameters.CloseDistance=200;
            Enemy.LightUnAwareVisionParameters.NarrowCone.Distance=5000;
            Enemy.LightUnAwareVisionParameters.NarrowCone.PeekingDistance=500;
            Enemy.LightUnAwareVisionParameters.NarrowCone.HorizontalAngle=90;
            Enemy.LightUnAwareVisionParameters.NarrowCone.VerticalAngle=45;
            Enemy.LightUnAwareVisionParameters.WideCone.Distance=800;
            Enemy.LightUnAwareVisionParameters.WideCone.PeekingDistance=200;
            Enemy.LightUnAwareVisionParameters.WideCone.HorizontalAngle=179;
            Enemy.LightUnAwareVisionParameters.WideCone.VerticalAngle=45;
            Enemy.LightUnAwareVisionParameters.WideConeReactionTime=0.0;
            Enemy.LightUnAwareVisionParameters.LoseTargetTime=10.0;
            Enemy.LightUnAwareVisionParameters.CrouchMultiplier=0.1;
            Enemy.NightvisionUnAwareVisionParameters.CloseDistance=200;
            Enemy.NightvisionUnAwareVisionParameters.NarrowCone.Distance=5000;
            Enemy.NightvisionUnAwareVisionParameters.NarrowCone.PeekingDistance=500;
            Enemy.NightvisionUnAwareVisionParameters.NarrowCone.HorizontalAngle=90;
            Enemy.NightvisionUnAwareVisionParameters.NarrowCone.VerticalAngle=45;
            Enemy.NightvisionUnAwareVisionParameters.WideCone.Distance=800;
            Enemy.NightvisionUnAwareVisionParameters.WideCone.PeekingDistance=200;
            Enemy.NightvisionUnAwareVisionParameters.WideCone.HorizontalAngle=179;
            Enemy.NightvisionUnAwareVisionParameters.WideCone.VerticalAngle=45;
            Enemy.NightvisionUnAwareVisionParameters.WideConeReactionTime=0.0;
            Enemy.NightvisionUnAwareVisionParameters.LoseTargetTime=10.0;
            Enemy.NightvisionUnAwareVisionParameters.CrouchMultiplier=0.1;
            Enemy.DarkUnAwareVisionParameters.CloseDistance=200;
            Enemy.DarkUnAwareVisionParameters.NarrowCone.Distance=5000;
            Enemy.DarkUnAwareVisionParameters.NarrowCone.PeekingDistance=500;
            Enemy.DarkUnAwareVisionParameters.NarrowCone.HorizontalAngle=90;
            Enemy.DarkUnAwareVisionParameters.NarrowCone.VerticalAngle=45;
            Enemy.DarkUnAwareVisionParameters.WideCone.Distance=800;
            Enemy.DarkUnAwareVisionParameters.WideCone.PeekingDistance=200;
            Enemy.DarkUnAwareVisionParameters.WideCone.HorizontalAngle=179;
            Enemy.DarkUnAwareVisionParameters.WideCone.VerticalAngle=45;
            Enemy.DarkUnAwareVisionParameters.WideConeReactionTime=0.0;
            Enemy.DarkUnAwareVisionParameters.LoseTargetTime=10.0;
            Enemy.DarkUnAwareVisionParameters.CrouchMultiplier=0.1;
            break;
        case EVT_Trippled:
            Enemy.LightAwareVisionParameters.CloseDistance=600;
            Enemy.LightAwareVisionParameters.NarrowCone.Distance=115000;
            Enemy.LightAwareVisionParameters.NarrowCone.PeekingDistance=1500;
            Enemy.LightAwareVisionParameters.NarrowCone.HorizontalAngle=90;
            Enemy.LightAwareVisionParameters.NarrowCone.VerticalAngle=90;
            Enemy.LightAwareVisionParameters.WideCone.Distance=2400;
            Enemy.LightAwareVisionParameters.WideCone.PeekingDistance=600;
            Enemy.LightAwareVisionParameters.WideCone.HorizontalAngle=210;
            Enemy.LightAwareVisionParameters.WideCone.VerticalAngle=135;
            Enemy.LightAwareVisionParameters.WideConeReactionTime=6.0;
            Enemy.LightAwareVisionParameters.LoseTargetTime=4.5;
            Enemy.LightAwareVisionParameters.CrouchMultiplier=1.5;
            Enemy.NightvisionAwareVisionParameters.CloseDistance=600;
            Enemy.NightvisionAwareVisionParameters.NarrowCone.Distance=115000;
            Enemy.NightvisionAwareVisionParameters.NarrowCone.PeekingDistance=1500;
            Enemy.NightvisionAwareVisionParameters.NarrowCone.HorizontalAngle=90;
            Enemy.NightvisionAwareVisionParameters.NarrowCone.VerticalAngle=90;
            Enemy.NightvisionAwareVisionParameters.WideCone.Distance=2400;
            Enemy.NightvisionAwareVisionParameters.WideCone.PeekingDistance=600;
            Enemy.NightvisionAwareVisionParameters.WideCone.HorizontalAngle=210;
            Enemy.NightvisionAwareVisionParameters.WideCone.VerticalAngle=135;
            Enemy.NightvisionAwareVisionParameters.WideConeReactionTime=6.0;
            Enemy.NightvisionAwareVisionParameters.LoseTargetTime=4.5;
            Enemy.NightvisionAwareVisionParameters.CrouchMultiplier=1.5;
            Enemy.DarkAwareVisionParameters.CloseDistance=600;
            Enemy.DarkAwareVisionParameters.NarrowCone.Distance=115000;
            Enemy.DarkAwareVisionParameters.NarrowCone.PeekingDistance=1500;
            Enemy.DarkAwareVisionParameters.NarrowCone.HorizontalAngle=90;
            Enemy.DarkAwareVisionParameters.NarrowCone.VerticalAngle=90;
            Enemy.DarkAwareVisionParameters.WideCone.Distance=2400;
            Enemy.DarkAwareVisionParameters.WideCone.PeekingDistance=600;
            Enemy.DarkAwareVisionParameters.WideCone.HorizontalAngle=210;
            Enemy.DarkAwareVisionParameters.WideCone.VerticalAngle=135;
            Enemy.DarkAwareVisionParameters.WideConeReactionTime=6.0;
            Enemy.DarkAwareVisionParameters.LoseTargetTime=4.5;
            Enemy.DarkAwareVisionParameters.CrouchMultiplier=1.5;
            Enemy.LightUnAwareVisionParameters.CloseDistance=600;
            Enemy.LightUnAwareVisionParameters.NarrowCone.Distance=115000;
            Enemy.LightUnAwareVisionParameters.NarrowCone.PeekingDistance=1500;
            Enemy.LightUnAwareVisionParameters.NarrowCone.HorizontalAngle=90;
            Enemy.LightUnAwareVisionParameters.NarrowCone.VerticalAngle=90;
            Enemy.LightUnAwareVisionParameters.WideCone.Distance=2400;
            Enemy.LightUnAwareVisionParameters.WideCone.PeekingDistance=600;
            Enemy.LightUnAwareVisionParameters.WideCone.HorizontalAngle=210;
            Enemy.LightUnAwareVisionParameters.WideCone.VerticalAngle=135;
            Enemy.LightUnAwareVisionParameters.WideConeReactionTime=6.0;
            Enemy.LightUnAwareVisionParameters.LoseTargetTime=4.5;
            Enemy.LightUnAwareVisionParameters.CrouchMultiplier=1.5;
            Enemy.NightvisionUnAwareVisionParameters.CloseDistance=1800;
            Enemy.NightvisionUnAwareVisionParameters.NarrowCone.Distance=11800;
            Enemy.NightvisionUnAwareVisionParameters.NarrowCone.PeekingDistance=1800;
            Enemy.NightvisionUnAwareVisionParameters.NarrowCone.HorizontalAngle=180;
            Enemy.NightvisionUnAwareVisionParameters.NarrowCone.VerticalAngle=180;
            Enemy.NightvisionUnAwareVisionParameters.WideCone.Distance=1500;
            Enemy.NightvisionUnAwareVisionParameters.WideCone.PeekingDistance=1800;
            Enemy.NightvisionUnAwareVisionParameters.WideCone.HorizontalAngle=90;
            Enemy.NightvisionUnAwareVisionParameters.WideCone.VerticalAngle=180;
            Enemy.NightvisionUnAwareVisionParameters.WideConeReactionTime=9.0;
            Enemy.NightvisionUnAwareVisionParameters.LoseTargetTime=3.0;
            Enemy.NightvisionUnAwareVisionParameters.CrouchMultiplier=1.5;
            Enemy.DarkUnAwareVisionParameters.CloseDistance=1800;
            Enemy.DarkUnAwareVisionParameters.NarrowCone.Distance=11800;
            Enemy.DarkUnAwareVisionParameters.NarrowCone.PeekingDistance=1800;
            Enemy.DarkUnAwareVisionParameters.NarrowCone.HorizontalAngle=180;
            Enemy.DarkUnAwareVisionParameters.NarrowCone.VerticalAngle=180;
            Enemy.DarkUnAwareVisionParameters.WideCone.Distance=1500;
            Enemy.DarkUnAwareVisionParameters.WideCone.PeekingDistance=1800;
            Enemy.DarkUnAwareVisionParameters.WideCone.HorizontalAngle=90;
            Enemy.DarkUnAwareVisionParameters.WideCone.VerticalAngle=180;
            Enemy.DarkUnAwareVisionParameters.WideConeReactionTime=9.0;
            Enemy.DarkUnAwareVisionParameters.LoseTargetTime=3.0;
            Enemy.DarkUnAwareVisionParameters.CrouchMultiplier=1.5;
            break;
        case EVT_EPEule:
            Enemy.LightAwareVisionParameters.CloseDistance=600;
            Enemy.LightAwareVisionParameters.NarrowCone.Distance=20000;
            Enemy.LightAwareVisionParameters.NarrowCone.PeekingDistance=5000;
            Enemy.LightAwareVisionParameters.NarrowCone.HorizontalAngle=180;
            Enemy.LightAwareVisionParameters.NarrowCone.VerticalAngle=90;
            Enemy.LightAwareVisionParameters.WideCone.Distance=19000;
            Enemy.LightAwareVisionParameters.WideCone.PeekingDistance=4900;
            Enemy.LightAwareVisionParameters.WideCone.HorizontalAngle=179;
            Enemy.LightAwareVisionParameters.WideCone.VerticalAngle=89;
            Enemy.LightAwareVisionParameters.WideConeReactionTime=0.1;
            Enemy.LightAwareVisionParameters.LoseTargetTime=4.5;
            Enemy.LightAwareVisionParameters.CrouchMultiplier=1.0;
            Enemy.NightvisionAwareVisionParameters.CloseDistance=600;
            Enemy.NightvisionAwareVisionParameters.NarrowCone.Distance=20000;
            Enemy.NightvisionAwareVisionParameters.NarrowCone.PeekingDistance=5000;
            Enemy.NightvisionAwareVisionParameters.NarrowCone.HorizontalAngle=180;
            Enemy.NightvisionAwareVisionParameters.NarrowCone.VerticalAngle=90;
            Enemy.NightvisionAwareVisionParameters.WideCone.Distance=19000;
            Enemy.NightvisionAwareVisionParameters.WideCone.PeekingDistance=4900;
            Enemy.NightvisionAwareVisionParameters.WideCone.HorizontalAngle=179;
            Enemy.NightvisionAwareVisionParameters.WideCone.VerticalAngle=89;
            Enemy.NightvisionAwareVisionParameters.WideConeReactionTime=0.1;
            Enemy.NightvisionAwareVisionParameters.LoseTargetTime=4.5;
            Enemy.NightvisionAwareVisionParameters.CrouchMultiplier=1.0;
            Enemy.DarkAwareVisionParameters.CloseDistance=600;
            Enemy.DarkAwareVisionParameters.NarrowCone.Distance=20000;
            Enemy.DarkAwareVisionParameters.NarrowCone.PeekingDistance=5000;
            Enemy.DarkAwareVisionParameters.NarrowCone.HorizontalAngle=180;
            Enemy.DarkAwareVisionParameters.NarrowCone.VerticalAngle=90;
            Enemy.DarkAwareVisionParameters.WideCone.Distance=19000;
            Enemy.DarkAwareVisionParameters.WideCone.PeekingDistance=4900;
            Enemy.DarkAwareVisionParameters.WideCone.HorizontalAngle=179;
            Enemy.DarkAwareVisionParameters.WideCone.VerticalAngle=89;
            Enemy.DarkAwareVisionParameters.WideConeReactionTime=0.1;
            Enemy.DarkAwareVisionParameters.LoseTargetTime=4.5;
            Enemy.DarkAwareVisionParameters.CrouchMultiplier=1.0;
            Enemy.LightUnAwareVisionParameters.CloseDistance=600;
            Enemy.LightUnAwareVisionParameters.NarrowCone.Distance=20000;
            Enemy.LightUnAwareVisionParameters.NarrowCone.PeekingDistance=5000;
            Enemy.LightUnAwareVisionParameters.NarrowCone.HorizontalAngle=180;
            Enemy.LightUnAwareVisionParameters.NarrowCone.VerticalAngle=90;
            Enemy.LightUnAwareVisionParameters.WideCone.Distance=19000;
            Enemy.LightUnAwareVisionParameters.WideCone.PeekingDistance=4900;
            Enemy.LightUnAwareVisionParameters.WideCone.HorizontalAngle=179;
            Enemy.LightUnAwareVisionParameters.WideCone.VerticalAngle=89;
            Enemy.LightUnAwareVisionParameters.WideConeReactionTime=0.1;
            Enemy.LightUnAwareVisionParameters.LoseTargetTime=4.5;
            Enemy.LightUnAwareVisionParameters.CrouchMultiplier=1.0;
            Enemy.NightvisionUnAwareVisionParameters.CloseDistance=600;
            Enemy.NightvisionUnAwareVisionParameters.NarrowCone.Distance=20000;
            Enemy.NightvisionUnAwareVisionParameters.NarrowCone.PeekingDistance=5000;
            Enemy.NightvisionUnAwareVisionParameters.NarrowCone.HorizontalAngle=180;
            Enemy.NightvisionUnAwareVisionParameters.NarrowCone.VerticalAngle=90;
            Enemy.NightvisionUnAwareVisionParameters.WideCone.Distance=19000;
            Enemy.NightvisionUnAwareVisionParameters.WideCone.PeekingDistance=4900;
            Enemy.NightvisionUnAwareVisionParameters.WideCone.HorizontalAngle=179;
            Enemy.NightvisionUnAwareVisionParameters.WideCone.VerticalAngle=89;
            Enemy.NightvisionUnAwareVisionParameters.WideConeReactionTime=0.1;
            Enemy.NightvisionUnAwareVisionParameters.LoseTargetTime=4.5;
            Enemy.NightvisionUnAwareVisionParameters.CrouchMultiplier=1.0;
            Enemy.DarkUnAwareVisionParameters.CloseDistance=600;
            Enemy.DarkUnAwareVisionParameters.NarrowCone.Distance=20000;
            Enemy.DarkUnAwareVisionParameters.NarrowCone.PeekingDistance=5000;
            Enemy.DarkUnAwareVisionParameters.NarrowCone.HorizontalAngle=180;
            Enemy.DarkUnAwareVisionParameters.NarrowCone.VerticalAngle=90;
            Enemy.DarkUnAwareVisionParameters.WideCone.Distance=19000;
            Enemy.DarkUnAwareVisionParameters.WideCone.PeekingDistance=4900;
            Enemy.DarkUnAwareVisionParameters.WideCone.HorizontalAngle=189;
            Enemy.DarkUnAwareVisionParameters.WideCone.VerticalAngle=89;
            Enemy.DarkUnAwareVisionParameters.WideConeReactionTime=0.1;
            Enemy.DarkUnAwareVisionParameters.LoseTargetTime=4.5;
            Enemy.DarkUnAwareVisionParameters.CrouchMultiplier=1.0;
            break;
        case EVT_EPAlt:
            Enemy.LightAwareVisionParameters.CloseDistance=120;
            Enemy.LightAwareVisionParameters.NarrowCone.Distance=5000;
            Enemy.LightAwareVisionParameters.NarrowCone.PeekingDistance=500;
            Enemy.LightAwareVisionParameters.NarrowCone.HorizontalAngle=30;
            Enemy.LightAwareVisionParameters.NarrowCone.VerticalAngle=30;
            Enemy.LightAwareVisionParameters.WideCone.Distance=800;
            Enemy.LightAwareVisionParameters.WideCone.PeekingDistance=200;
            Enemy.LightAwareVisionParameters.WideCone.HorizontalAngle=70;
            Enemy.LightAwareVisionParameters.WideCone.VerticalAngle=50;
            Enemy.LightAwareVisionParameters.WideConeReactionTime=0.0;
            Enemy.LightAwareVisionParameters.LoseTargetTime=3.0;
            Enemy.LightAwareVisionParameters.CrouchMultiplier=1.0;
            Enemy.NightvisionAwareVisionParameters.CloseDistance=200;
            Enemy.NightvisionAwareVisionParameters.NarrowCone.Distance=5000;
            Enemy.NightvisionAwareVisionParameters.NarrowCone.PeekingDistance=500;
            Enemy.NightvisionAwareVisionParameters.NarrowCone.HorizontalAngle=30;
            Enemy.NightvisionAwareVisionParameters.NarrowCone.VerticalAngle=30;
            Enemy.NightvisionAwareVisionParameters.WideCone.Distance=800;
            Enemy.NightvisionAwareVisionParameters.WideCone.PeekingDistance=200;
            Enemy.NightvisionAwareVisionParameters.WideCone.HorizontalAngle=70;
            Enemy.NightvisionAwareVisionParameters.WideCone.VerticalAngle=50;
            Enemy.NightvisionAwareVisionParameters.WideConeReactionTime=0.0;
            Enemy.NightvisionAwareVisionParameters.LoseTargetTime=3.0;
            Enemy.NightvisionAwareVisionParameters.CrouchMultiplier=1.0;
            Enemy.DarkAwareVisionParameters.CloseDistance=200;
            Enemy.DarkAwareVisionParameters.NarrowCone.Distance=5000;
            Enemy.DarkAwareVisionParameters.NarrowCone.PeekingDistance=500;
            Enemy.DarkAwareVisionParameters.NarrowCone.HorizontalAngle=30;
            Enemy.DarkAwareVisionParameters.NarrowCone.VerticalAngle=30;
            Enemy.DarkAwareVisionParameters.WideCone.Distance=800;
            Enemy.DarkAwareVisionParameters.WideCone.PeekingDistance=200;
            Enemy.DarkAwareVisionParameters.WideCone.HorizontalAngle=70;
            Enemy.DarkAwareVisionParameters.WideCone.VerticalAngle=50;
            Enemy.DarkAwareVisionParameters.WideConeReactionTime=0.0;
            Enemy.DarkAwareVisionParameters.LoseTargetTime=3.0;
            Enemy.DarkAwareVisionParameters.CrouchMultiplier=1.0;
            Enemy.LightUnAwareVisionParameters.CloseDistance=200;
            Enemy.LightUnAwareVisionParameters.NarrowCone.Distance=5000;
            Enemy.LightUnAwareVisionParameters.NarrowCone.PeekingDistance=500;
            Enemy.LightUnAwareVisionParameters.NarrowCone.HorizontalAngle=30;
            Enemy.LightUnAwareVisionParameters.NarrowCone.VerticalAngle=30;
            Enemy.LightUnAwareVisionParameters.WideCone.Distance=800;
            Enemy.LightUnAwareVisionParameters.WideCone.PeekingDistance=200;
            Enemy.LightUnAwareVisionParameters.WideCone.HorizontalAngle=70;
            Enemy.LightUnAwareVisionParameters.WideCone.VerticalAngle=45;
            Enemy.LightUnAwareVisionParameters.WideConeReactionTime=0.0;
            Enemy.LightUnAwareVisionParameters.LoseTargetTime=3.0;
            Enemy.LightUnAwareVisionParameters.CrouchMultiplier=1.0;
            Enemy.NightvisionUnAwareVisionParameters.CloseDistance=200;
            Enemy.NightvisionUnAwareVisionParameters.NarrowCone.Distance=5000;
            Enemy.NightvisionUnAwareVisionParameters.NarrowCone.PeekingDistance=500;
            Enemy.NightvisionUnAwareVisionParameters.NarrowCone.HorizontalAngle=30;
            Enemy.NightvisionUnAwareVisionParameters.NarrowCone.VerticalAngle=30;
            Enemy.NightvisionUnAwareVisionParameters.WideCone.Distance=800;
            Enemy.NightvisionUnAwareVisionParameters.WideCone.PeekingDistance=200;
            Enemy.NightvisionUnAwareVisionParameters.WideCone.HorizontalAngle=70;
            Enemy.NightvisionUnAwareVisionParameters.WideCone.VerticalAngle=45;
            Enemy.NightvisionUnAwareVisionParameters.WideConeReactionTime=0.0;
            Enemy.NightvisionUnAwareVisionParameters.LoseTargetTime=3.0;
            Enemy.NightvisionUnAwareVisionParameters.CrouchMultiplier=1.0;
            Enemy.DarkUnAwareVisionParameters.CloseDistance=200;
            Enemy.DarkUnAwareVisionParameters.NarrowCone.Distance=5000;
            Enemy.DarkUnAwareVisionParameters.NarrowCone.PeekingDistance=500;
            Enemy.DarkUnAwareVisionParameters.NarrowCone.HorizontalAngle=30;
            Enemy.DarkUnAwareVisionParameters.NarrowCone.VerticalAngle=30;
            Enemy.DarkUnAwareVisionParameters.WideCone.Distance=800;
            Enemy.DarkUnAwareVisionParameters.WideCone.PeekingDistance=200;
            Enemy.DarkUnAwareVisionParameters.WideCone.HorizontalAngle=70;
            Enemy.DarkUnAwareVisionParameters.WideCone.VerticalAngle=45;
            Enemy.DarkUnAwareVisionParameters.WideConeReactionTime=0.0;
            Enemy.DarkUnAwareVisionParameters.LoseTargetTime=3.0;
            Enemy.DarkUnAwareVisionParameters.CrouchMultiplier=1.0;
            break;
    }
    Enemy.HearingThreshold=Hearing;
    return self;
}
// VisionAndHearing end

Function EnemyUtils SetEnemyAttackAndDoor(float Range =170.0, float SQRange =1000, float Grab =0.99, float PushKB =15, float Delay =0.01, float Normal =101, float Throw =101, float Vault =101, float Door =101, int Bashes =0, float PathMultiplier =3)
{
    Enemy.AttackRange=Range;
    Enemy.AttackSqueezeRange=SQRange;
    Enemy.AttackGrabChance=Grab;
    Enemy.AttackPushKnockbackPower=PushKB;
    Enemy.AttackNormalRecovery=Delay;
    Enemy.AttackNormalDamage=Normal;
    Enemy.AttackThrowDamage=Throw;
    Enemy.DoorBashDamage=Door;
    Enemy.VaultDamage=Vault;
    Enemy.NumOfDoorBashLoops=Bashes;
    Enemy.DoorClosedPathMultiplier=PathMultiplier;
    Enemy.AttackQuickDistanceThreshold=Range-10;
    return self;
}

Function EnemyUtils SetEnemyInvestigation(int InvPoints =8, float Min =200, float Max =600, float Angle =60, float PathDist =1200, float NPrio =1, float LockerPrio =10, float LockerOcPrio =10, float BedPrio=10, float BedOcPrio =10, float findProb =0.99, float NWait =1, float CWait =1, float BedAlternate =0, bool Beds =true, bool Lockers =true, bool PrefPaths =true)
{
    Enemy.InvestigationNumPointsGenerated=InvPoints;
    Enemy.InvestigationMinRadius=Min;
    Enemy.InvestigationMaxRadius=Max;
    Enemy.InvestigationMaxPathDistance=PathDist;
    Enemy.InvestigationFirstPointAngle=Angle;
    Enemy.InvestigationNormalWeight=NPrio;
    Enemy.InvestigationLockerWeight=LockerPrio;
    Enemy.InvestigationLockerOccupiedWeight=LockerOcPrio;
    Enemy.InvestigationBedWeight=BedPrio;
    Enemy.InvestigationBedOccupiedWeight=BedOcPrio;
    Enemy.InvestigationFindHiddenPlayerProbability=findProb;
    Enemy.WaitLeaveNormalMultiplier=NWait;
    Enemy.WaitLeaveChaseMultiplier=CWait;
    Enemy.bInvestigateLockers=Lockers;
    Enemy.bInvestigateBeds=Beds;
    Enemy.bUsePreferredPaths=PrefPaths;
    Enemy.InvestigateBedAlternateChance=BedAlternate;
    return self;
}

Function EnemyUtils SetStaticEnemyValues()
{
    Enemy.MoveReactionTime =0.7;
    Enemy.UnstuckCheckTime=0.33;
    Enemy.LookAheadDistance=100;
    Enemy.LookAheadUpdateTime=0.33;
    Enemy.AttackSqueezeCycleTime=5.0;
    Enemy.DoorBashKnockbackPower=30;
    Enemy.VaultKnockbackPower=30;
    Enemy.AttackQuickAngleThreshold=45;
    Enemy.AttackQuickSpeedThreshold=150;
    Enemy.bAttackUseQuickAttack=true;
    return self;
}

Function EnemyUtils NoHide(bool Enable =true)
{
    Enemy.Bot.SightComponent.bAlwaysSeeTarget=enable;
    Enemy.Bot.SightComponent.bSawPlayerEnterHidingSpot = enable;
    Enemy.Bot.SightComponent.bSawPlayerEnterBed = enable;
    Enemy.Bot.SightComponent.bSawPlayerGoUnder = enable;
    return self;
}

function EnemyUtils SetLocationAndRotation(Vector v, Rotator r){
    Enemy.SetLocation(v);
    Enemy.SetRotation(r);
    return self;
}

Function Kill(Optional OLEnemyPawn P) 
{
    local OLEnemyPawn E;
    
    if(P ==None)
    {
        ForEach WI.DynamicActors(Class'OLEnemyPawn', E)
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

Function BackPawnColl()
{
    Local OLEnemyPawn P;
    ForEach WI.AllPawns(Class'OLEnemyPawn', P)
    {
        P.SetCollision(true,true,true);
    }
}