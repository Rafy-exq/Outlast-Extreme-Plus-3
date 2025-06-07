class MeshList extends Object;

var const SkeletalMesh GroomMesh, TragerMesh, MartinMesh, DefaultPatientMesh;

static function SkeletalMesh GetRandomMesh(){
    local array<SkeletalMesh> Meshes;
    local int I;

    Meshes =GetMeshList();
    I =Rand(Meshes.Length);
    return Meshes[I];
}

static function array<SkeletalMesh> GetMeshList(){
    local array<SkeletalMesh> Meshes;

    Meshes[0] =SkeletalMesh'02_Priest.Pawn.Priest-01';
    Meshes[1] =SkeletalMesh'Prison_01-LD.Duponts.Mesh.Dupont';
    Meshes[2] =SkeletalMesh'Prison_01-LD.Duponts.Mesh.Dupont_2';
    Meshes[3] =SkeletalMesh'DLC_PrisonFloor2-01_LD.02_Scientist_DLC.Guard_alive';
    Meshes[4] =SkeletalMesh'Prison_01-LD.02_Generic_Worker.Mesh.Guard';
    Meshes[5] =SkeletalMesh'Prison_01-LD.02_Generic_Patient_2nd_package.Mesh.Rape_victim';
    Meshes[6] =SkeletalMesh'Prison_01-LD.02_Generic_Patient_2nd_package.Mesh.Patient_19_wound';
    Meshes[7] =SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_8';
    Meshes[8] =SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_7';
    Meshes[9] =SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_6';
    Meshes[10] =SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_4';
    Meshes[11] =SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_3';
    Meshes[12] =SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_21';
    Meshes[13] =SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_2';
    Meshes[14] =SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_19';
    Meshes[15] =SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_18';
    Meshes[16] =SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_17';
    Meshes[17] =SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_16';
    Meshes[18] =SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_12';
    Meshes[19] =SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_1';
    Meshes[20] =SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_11';
    
    Meshes[21] =SkeletalMesh'FemaleWard_Floor1-LD.02_Generic_Patient.Meshes.Patient_14';
    Meshes[22] =SkeletalMesh'FemaleWard_Floor2-LD.02_Generic_Patient.Meshes.Patient_15';
    Meshes[23] =SkeletalMesh'Male_ward_03a-SE.02_Generic_Patient.Meshes.Patient_5';
    Meshes[24] =SkeletalMesh'Male_ward_LD.02_Generic_Worker.Mesh.Worker_01';
    Meshes[25] =SkeletalMesh'Sewers_LD.02_Generic_Patient.Meshes.Patient_9';
    Meshes[26] =SkeletalMesh'Center_block_03-LD.02_Priest.Pawn.Priest-burned';
    Meshes[27] =SkeletalMesh'Center_block_sript_Revisit.02_Generic_Worker.Mesh.worker_4';
    Meshes[28] =SkeletalMesh'Center_block_sript.02_Generic_Worker.Mesh.worker_3';
    Meshes[29] =SkeletalMesh'Male_ward_Cafeteria_fire.02_Generic_Patient_2nd_package.Mesh.pyro_dialogue';
    Meshes[30] =SkeletalMesh'DLC_PrisonFloor2-01_SE.02_Blair.Blair';
    Meshes[31] =SkeletalMesh'DLC_AdmFloor1-01_SE.02_Blair.Blair_exploded';
    
    Meshes[32] =SkeletalMesh'DLC_PrisonFloor2-01_SE.02_Generic_Patient.Meshes.Patient_13';
    Meshes[33] =SkeletalMesh'DLC_PrisonCourtYard-01_LD.02_Generic_Patient_DLC.Meshes.Patient_10';
    Meshes[34] =SkeletalMesh'DLC_MaleFloor2-01_SE.02_Swat.Mesh.Swat_v3';
    Meshes[35] =SkeletalMesh'DLC_MaleFloor2-01_SE.02_Swat.Mesh.Swat_v2';
    Meshes[36] =SkeletalMesh'DLC_MaleFloor2-01_SE.02_Swat.Mesh.Swat_v1';    
    Meshes[37] =SkeletalMesh'DLC_Lab-01_SE.02_Scientist_DLC.Scientist_Licker';
    Meshes[38] =SkeletalMesh'DLC_Lab-01_SE.02_Scientist_DLC.masked_scientist';
    Meshes[39] =SkeletalMesh'DLC_Lab-01_SE.02_Scientist_DLC.hazmat_scientist';
    Meshes[40] =SkeletalMesh'DLC_Build1Floor2-01_SE.02_Scientist_DLC.Mesh.Scientist';
    Meshes[41] =SkeletalMesh'DLC_Lab-01_SE.02_Generic_Worker_DLC.worker_4';
    
    Meshes[42] =SkeletalMesh'DLC_Build2Attic-01_LD.02_Generic_Worker.Mesh.Worker_02';
    Meshes[43] =SkeletalMesh'DLC_Build2Floor3-01_LD.02_Generic_Patient_DLC.Meshes.Patient_20';
    Meshes[44] =SkeletalMesh'DLC_Build1Floor1-01_SE.02_Scientist_DLC.Mesh.Scientist_03';
    Meshes[45] =SkeletalMesh'DLC_Build1Floor1-01_SE.02_Scientist_DLC.Mesh.Scientist_02';
    Meshes[46] =SkeletalMesh'DLC_Build1Floor1-01_SE.02_Generic_Worker.Mesh.Worker_01_headless';
    return Meshes;
}

defaultproperties
{
    GroomMesh =SkeletalMesh'DLC_Build2Exterior-01_LD.02_Groom.Groom_Shirt'
    MartinMesh =SkeletalMesh'02_Priest.Pawn.Priest-01'
    TragerMesh =SkeletalMesh'Male_ward_SE.02_Surgeon.Mesh.Surgeon'
    DefaultPatientMesh =SkeletalMesh'Prison_01-LD.02_Generic_Patient.Meshes.Patient_19'
}