Class EPGame extends OLGame;

static event class<GameInfo> SetGameType(string MapName, string Options, string Portal) 
{
    return Default.class;
}

DefaultProperties
{
	DefaultPawnClass=class'EPlus.EPHero'
    PlayerControllerClass=Class'Eplus.EPController'
    HUDType=Class'Eplus.EPHud'
}