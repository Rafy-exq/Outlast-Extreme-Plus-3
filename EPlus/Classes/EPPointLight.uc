Class EPPointLight extends PointLightMovable
	placeable;

var PointLightComponent EPPointLightComponent;

Function OnTurn(Bool Enable) {
	LightComponent.SetEnabled(Enable);
}

Function SetBrightness(Float Brightness) {
	LightComponent.SetLightProperties(Brightness);
    LightComponent.UpdateColorAndBrightness();
}

Function SetColor(Byte Red, Byte Green, Byte Blue, Byte Alpha) {
	local Color NewColor;
	
	NewColor.R = Red;
	NewColor.G = Green;
	NewColor.B = Blue;
	NewColor.A = Alpha;

	LightComponent.SetLightProperties(,NewColor); 
    LightComponent.UpdateColorAndBrightness();
}

Function SetRadius(Float Radius=1024.0) {
	PointLightComponent(LightComponent).Radius = Radius;
}

Function SetFallOffExponent(Float Exp=2.0) {
	PointLightComponent(LightComponent).FalloffExponent = Exp;
}

Function SetShadowFalloffExponent(Float Exp=2.0) {
	PointLightComponent(LightComponent).ShadowFalloffExponent = Exp;
}

Function SetShadowRadiusMultiplier(Float Mul=1.1) {
	PointLightComponent(LightComponent).ShadowRadiusMultiplier = Mul;
}

Function SetCastDynamicShadows(Bool Cast=true) {
	LightComponent.CastDynamicShadows = Cast;
}

DefaultProperties
{
    bNoDelete=FALSE
	CastShadows=false
	bStatic=FALSE
	CastStaticShadows=TRUE
	CastDynamicShadows=TRUE
	bForceDynamicLight=TRUE
	UseDirectLightMap=FALSE
	bAllowPreShadow=TRUE
	bPrecomputedLightingIsValid=false
	LightAffectsClassification=ELightAffectsClassification.LAC_DYNAMIC_AND_STATIC_AFFECTING
    LightShadowMode=ELightShadowMode.LightShadow_Normal
	LightComponent.LightingChannels=(bInitialized=True,BSP=True,Static=True,Dynamic=True,CompositeDynamic=True,Skybox=True,Unnamed_1=True,Unnamed_2=True,Unnamed_3=True,Unnamed_4=True,Unnamed_5=True,Unnamed_6=True,Cinematic_1=True,Cinematic_2=True,Cinematic_3=True,Cinematic_4=True,Cinematic_5=True,Dynamic_1=True,Dynamic_2=True,Dynamic_3=True,Dynamic_4=True,Dynamic_5=True,Gameplay_1=True,Gameplay_2=True,Gameplay_3=True,Gameplay_4=True)
    bCollideActors=FALSE
	bCollideWorld=FALSE
	bBlockActors=FALSE
}