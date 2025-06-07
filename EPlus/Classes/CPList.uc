class CPList extends Object
abstract;

/**
 * Returns true if an specified name is an Outlast Checkpoint.
 * @param CP: the name to check if it is an Outlast Checkpoint.
 * @return true if the name is an Outlast CP.
 */
static final function bool IsCP(name CP){
    local Array<Name> FullList;

    FullList =GetFullCPList();
    return FullList.find(cp) !=-1;
}

/**
 * returns the name of the previous Checkpoint.
 * Previous meaning the Checkpoint that would have been reached before the given one in an normal playthrough.
 * If the given Checkpoint is the first of either WB or the Maingame, 'error' is returned.
 * @param StartCP: The Checkpoint name to determine which Checkpoint is the previous one.
 * @return The name of the previous Checkpoint.
 */
static final function Name GetPreviousCP(Name StartCP){
    local int Index;
    Local Array<Name> CPList;

    CPList =GetCPList();
    Index =CPList.find(StartCP);
    if(Index >0){
        return CPList[Index -1];
    }

    CPList =GetCPList(true);
    Index =CPList.find(StartCP);
    if(Index >0){
        return CPList[Index -1];
    }
    return 'error';
}

/**
 * Returns a list containing all Checkpoint names in chronological order.
 * MainGame Checkpoints first, then WB ones.
 * @return Array<name> containing the Checkpoint names.
 */
Static final Function Array<Name> GetFullCPList(){
    local Name N;
    local Array<Name> MG, WB;

    MG =GetCPList();
    WB =GetCPList(true);

    foreach WB(N){
        MG.AddItem(N);
    }
    return MG;
}

/**
 * Checks if the given Checkpoint has/could have an encounter with an attacking enemy, 
 * What counts as an enemypart is subjective, please adjust the function to your needs.
 * @param CP: the name to check against.
 * @return true if the name is defined as an chasecp.
 */
static final function bool ISChaseCP(Name CP){
    local Array<Name> ChaseList;

    ChaseList.AddItem('Admin_SecurityRoom');
    ChaseList.AddItem('Admin_Basement');
    ChaseList.AddItem('Admin_Electricity');
    ChaseList.AddItem('Prison_PrisonFloor_3rdFloor');
    ChaseList.AddItem('Prison_PrisonFloor_SecurityRoom1');
    ChaseList.AddItem('Prison_Showers_2ndFloor');
    ChaseList.AddItem('Prison_PrisonFloor02_SecurityRoom2');
    ChaseList.AddItem('Prison_IsolationCells02_Soldier');
    ChaseList.AddItem('Prison_OldCells_PreStruggle2');
    ChaseList.AddItem('Sewer_FlushWater');
    ChaseList.AddItem('Sewer_WaterFlushed');
    ChaseList.AddItem('Sewer_Citern2');
    ChaseList.AddItem('Sewer_PostCitern');
    ChaseList.AddItem('Male_Chase');
    ChaseList.AddItem('Male_ChasePause');
    ChaseList.AddItem('Male_TortureDone');
    ChaseList.AddItem('Male_surgeon');
    ChaseList.AddItem('Male_GetTheKey2');
    ChaseList.AddItem('Male_SprinklerOff');
    ChaseList.AddItem('Male_SprinklerOn');
    ChaseList.AddItem('Courtyard_Corridor');
    ChaseList.AddItem('Courtyard_Soldier1');
    ChaseList.AddItem('Courtyard_Soldier2');
    ChaseList.AddItem('Female_2ndFloor');
    ChaseList.AddItem('Female_2ndfloorChute');
    ChaseList.AddItem('Female_ChuteActivated');
    ChaseList.AddItem('Female_Keypickedup');
    ChaseList.AddItem('Female_3rdFloor');
    ChaseList.AddItem('Female_3rdFloorPosthole');
    ChaseList.AddItem('Female_FoundCam');
    ChaseList.AddItem('Revisit_Soldier1');
    ChaseList.AddItem('Revisit_FoundKey');
    ChaseList.AddItem('Revisit_To3rdfloor');
    ChaseList.AddItem('Revisit_Soldier3');
    ChaseList.AddItem('Lab_SwarmIntro2');
    ChaseList.AddItem('Lab_SwarmCafeteria');
    ChaseList.AddItem('Lab_BigRoomDone');
    ChaseList.AddItem('Lab_BigTower');
    ChaseList.AddItem('Lab_BigTowerStairs');
    ChaseList.AddItem('Lab_BigTowerDone');
    ChaseList.AddItem('Hospital_Free');
    ChaseList.AddItem('Hospital_1stFloor_ChaseStart');
    ChaseList.AddItem('Hospital_1stFloor_SAS');
    ChaseList.AddItem('Hospital_1stFloor_NeedHandCuff');
    ChaseList.AddItem('Hospital_1stFloor_Chase');
    ChaseList.AddItem('Hospital_2ndFloor_Canibalrun');
    ChaseList.AddItem('Hospital_2ndFloor_RoomsCorridor');
    ChaseList.AddItem('Hospital_2ndFloor_Start_Lab_2nd');
    ChaseList.AddItem('Hospital_2ndFloor_GazOff');
    ChaseList.AddItem('Courtyard1_DupontIntro');
    ChaseList.AddItem('Courtyard1_Basketball');
    ChaseList.AddItem('PrisonRevisit_Radio');
    ChaseList.AddItem('PrisonRevisit_Chase');
    ChaseList.AddItem('Courtyard2_ElectricityOff_2');
    ChaseList.AddItem('Building2_Attic_Denis');
    ChaseList.AddItem('Building2_Floor3_2');
    ChaseList.AddItem('Building2_Floor3_3');
    ChaseList.AddItem('Building2_Floor3_4');
    ChaseList.AddItem('Building2_TortureDone');
    ChaseList.AddItem('Building2_Floor1_4');

    return ChaseList.Find(CP) !=-1;
}

/**
 * Getter for a list of Checkpoint names of either MainGame or WB. Sorted in chronological order.
 * @param WB: if true get the WB Checkpoint names. If false Maingame ones.
 * @return Array<name>
 */
Static final Function Array<Name> GetCPList(bool WB =false){
    Local Array<Name> MGCps, WBCPs;

    if(!WB){
        MGCPs[0]='StartGame';
        MGCPs[1]='Admin_Gates';
        MGCPs[2]='Admin_Garden';
        MGCPs[3]='Admin_Explosion';
        MGCPs[4]='Admin_Mezzanine';
        MGCPs[5]='Admin_MainHall';
        MGCPs[6]='Admin_WheelChair';
        MGCPs[7]='Admin_SecurityRoom';
        MGCPs[8]='Admin_Basement';
        MGCPs[9]='Admin_Electricity';
        MGCPs[10]='Admin_PostBasement';
        MGCPs[11]='Prison_Start';
        MGCPs[12]='Prison_IsolationCells01_Mid';
        MGCPs[13]='Prison_ToPrisonFloor';
        MGCPs[14]='Prison_PrisonFloor_3rdFloor';
        MGCPs[15]='Prison_PrisonFloor_SecurityRoom1';
        MGCPs[16]='Prison_PrisonFloor02_IsolationCells01';
        MGCPs[17]='Prison_Showers_2ndFloor';
        MGCPs[18]='Prison_PrisonFloor02_PostShowers';
        MGCPs[19]='Prison_PrisonFloor02_SecurityRoom2';
        MGCPs[20]='Prison_IsolationCells02_Soldier';
        MGCPs[21]='Prison_IsolationCells02_PostSoldier';
        MGCPs[22]='Prison_OldCells_PreStruggle';
        MGCPs[23]='Prison_OldCells_PreStruggle2';
        MGCPs[24]='Prison_Showers_Exit';
        MGCPs[25]='Sewer_start';
        MGCPs[26]='Sewer_FlushWater';
        MGCPs[27]='Sewer_WaterFlushed';
        MGCPs[28]='Sewer_Ladder';
        MGCPs[29]='Sewer_ToCitern';
        MGCPs[30]='Sewer_Citern1';
        MGCPs[31]='Sewer_Citern2';
        MGCPs[32]='Sewer_PostCitern';
        MGCPs[33]='Sewer_ToMaleWard';
        MGCPs[34]='Male_Start';
        MGCPs[35]='Male_Chase';
        MGCPs[36]='Male_ChasePause';
        MGCPs[37]='Male_Torture';
        MGCPs[38]='Male_TortureDone';
        MGCPs[39]='Male_surgeon';
        MGCPs[40]='Male_GetTheKey';
        MGCPs[41]='Male_GetTheKey2';
        MGCPs[42]='Male_Elevator';
        MGCPs[43]='Male_ElevatorDone';
        MGCPs[44]='Male_Priest';
        MGCPs[45]='Male_Cafeteria';
        MGCPs[46]='Male_SprinklerOff';
        MGCPs[47]='Male_SprinklerOn';
        MGCPs[48]='Courtyard_Start';
        MGCPs[49]='Courtyard_Corridor';
        MGCPs[50]='Courtyard_Chapel';
        MGCPs[51]='Courtyard_Soldier1';
        MGCPs[52]='Courtyard_Soldier2';
        MGCPs[53]='Courtyard_FemaleWard';
        MGCPs[54]='Female_Start';
        MGCPs[55]='Female_Mainchute';
        MGCPs[56]='Female_2ndFloor';
        MGCPs[57]='Female_2ndfloorChute';
        MGCPs[58]='Female_ChuteActivated';
        MGCPs[59]='Female_Keypickedup';
        MGCPs[60]='Female_3rdFloor';
        MGCPs[61]='Female_3rdFloorHole';
        MGCPs[62]='Female_3rdFloorPosthole';
        MGCPs[63]='Female_Tobigjump';
        MGCPs[64]='Female_LostCam';
        MGCPs[65]='Female_FoundCam';
        MGCPs[66]='Female_Chasedone';
        MGCPs[67]='Female_Exit';
        MGCPs[68]='Female_Jump';
        MGCPs[69]='Revisit_Soldier1';
        MGCPs[70]='Revisit_Mezzanine';
        MGCPs[71]='Revisit_ToRH';
        MGCPs[72]='Revisit_RH';
        MGCPs[73]='Revisit_FoundKey';
        MGCPs[74]='Revisit_To3rdfloor';
        MGCPs[75]='Revisit_3rdFloor';
        MGCPs[76]='Revisit_RoomCrack';
        MGCPs[77]='Revisit_ToChapel';
        MGCPs[78]='Revisit_PriestDead';
        MGCPs[79]='Revisit_Soldier3';
        MGCPs[80]='Revisit_ToLab';
        MGCPs[81]='Lab_Start';
        MGCPs[82]='Lab_PremierAirlock';
        MGCPs[83]='Lab_SwarmIntro';
        MGCPs[84]='Lab_SwarmIntro2';
        MGCPs[85]='Lab_Soldierdead';
        MGCPs[86]='Lab_SpeachDone';
        MGCPs[87]='Lab_SwarmCafeteria';
        MGCPs[88]='Lab_EBlock';
        MGCPs[89]='Lab_ToBilly';
        MGCPs[90]='Lab_BigRoom';
        MGCPs[91]='Lab_BigRoomDone';
        MGCPs[92]='Lab_BigTower';
        MGCPs[93]='Lab_BigTowerStairs';
        MGCPs[94]='Lab_BigTowerMid';
        MGCPs[95]='Lab_BigTowerDone';
        return MGCPs;
    }
    else{    
        WBCPs[0]='DLC_Start';
        WBCPs[1]='DLC_Lab_Start';
        WBCPs[2]='Lab_AfterExperiment';
        WBCPs[3]='Hospital_Start';
        WBCPs[4]='Hospital_Free';
        WBCPs[5]='Hospital_1stFloor_ChaseStart';
        WBCPs[6]='Hospital_1stFloor_ChaseEnd';
        WBCPs[7]='Hospital_1stFloor_dropairvent';
        WBCPs[8]='Hospital_1stFloor_SAS';
        WBCPs[9]='Hospital_1stFloor_Lobby';
        WBCPs[10]='Hospital_1stFloor_NeedHandCuff';
        WBCPs[11]='Hospital_1stFloor_GotKey';
        WBCPs[12]='Hospital_1stFloor_Chase';
        WBCPs[13]='Hospital_1stFloor_Crema';
        WBCPs[14]='Hospital_1stFloor_Bake';
        WBCPs[15]='Hospital_1stFloor_Crema2';
        WBCPs[16]='Hospital_2ndFloor_Crema';
        WBCPs[17]='Hospital_2ndFloor_Canibalrun';
        WBCPs[18]='Hospital_2ndFloor_Canibalgone';
        WBCPs[19]='Hospital_2ndFloor_ExitIsLocked';
        WBCPs[20]='Hospital_2ndFloor_RoomsCorridor';
        WBCPs[21]='Hospital_2ndFloor_ToLab';
        WBCPs[22]='Hospital_2ndFloor_Start_Lab_2nd';
        WBCPs[23]='Hospital_2ndFloor_GazOff';
        WBCPs[24]='Hospital_2ndFloor_Labdone';
        WBCPs[25]='Hospital_2ndFloor_Exit';
        WBCPs[26]='Courtyard1_Start';
        WBCPs[27]='Courtyard1_RecreationArea';
        WBCPs[28]='Courtyard1_DupontIntro';
        WBCPs[29]='Courtyard1_Basketball';
        WBCPs[30]='Courtyard1_SecurityTower';
        WBCPs[31]='PrisonRevisit_Start';
        WBCPs[32]='PrisonRevisit_Radio';
        WBCPs[33]='PrisonRevisit_Priest';
        WBCPs[34]='PrisonRevisit_Tochase';
        WBCPs[35]='PrisonRevisit_Chase';
        WBCPs[36]='Courtyard2_Start';
        WBCPs[37]='Courtyard2_FrontBuilding2';
        WBCPs[38]='Courtyard2_ElectricityOff';
        WBCPs[39]='Courtyard2_ElectricityOff_2';
        WBCPs[40]='Courtyard2_ToWaterTower';
        WBCPs[41]='Courtyard2_WaterTower';
        WBCPs[42]='Courtyard2_TopWaterTower';
        WBCPs[43]='Building2_Start';
        WBCPs[44]='Building2_Attic_Mid';
        WBCPs[45]='Building2_Attic_Denis';
        WBCPs[46]='Building2_Floor3_1';
        WBCPs[47]='Building2_Floor3_2';
        WBCPs[48]='Building2_Floor3_3';
        WBCPs[49]='Building2_Floor3_4';
        WBCPs[50]='Building2_Elevator';
        WBCPs[51]='Building2_Post_Elevator';
        WBCPs[52]='Building2_Torture';
        WBCPs[53]='Building2_TortureDone';
        WBCPs[54]='Building2_Garden';
        WBCPs[55]='Building2_Floor1_1';
        WBCPs[56]='Building2_Floor1_2';
        WBCPs[57]='Building2_Floor1_3';
        WBCPs[58]='Building2_Floor1_4';
        WBCPs[59]='Building2_Floor1_5';
        WBCPs[60]='Building2_Floor1_5b';
        WBCPs[61]='Building2_Floor1_6';
        WBCPs[62]='MaleRevisit_Start';
        WBCPs[63]='AdminBlock_Start';
        return WBCPs;
    }
}