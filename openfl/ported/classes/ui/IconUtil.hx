package classes.ui;

import assets.menu.icons.fa.*;
import openfl.display.Sprite;

class IconUtil
{
    public static function getIcon(name : String) : Sprite
    {
        switch (name)
        {
            case "iconPlay":
                return new IconPlay();
            case "iconFilter":
                return new IconFilter();
            case "iconAward":
                return new IconAward();
            case "iconClose":
                return new IconClose();
            case "iconCopy":
                return new IconCopy();
            case "iconDelete":
                return new IconDelete();
            case "iconFilm":
                return new IconFilm();
            case "iconFilter":
                return new IconFilter();
            case "iconFolder":
                return new IconFolder();
            case "iconGear":
                return new IconGear();
            case "iconHeartEmpty":
                return new IconHeartEmpty();
            case "iconHeartFull":
                return new IconHeartFull();
            case "iconLeft":
                return new IconLeft();
            case "iconList":
                return new IconList();
            case "iconMap":
                return new IconMap();
            case "iconMedal":
                return new IconMedal();
            case "iconMinus":
                return new IconMinus();
            case "iconMusic":
                return new IconMusic();
            case "iconPause":
                return new IconPause();
            case "iconPhoto":
                return new IconPhoto();
            case "iconPlay":
                return new IconPlay();
            case "iconPlus":
                return new IconPlus();
            case "iconRandom":
                return new IconRandom();
            case "iconRecord":
                return new IconRecord();
            case "iconRefresh":
                return new IconRefresh();
            case "iconRight":
                return new IconRight();
            case "iconSave":
                return new IconSave();
            case "iconSearch":
                return new IconSearch();
            case "iconSpeed":
                return new IconSpeed();
            case "iconStar":
                return new IconStar();
            case "iconStop":
                return new IconStop();
            case "iconTime":
                return new IconTime();
            case "iconTrophy":
                return new IconTrophy();
            case "iconUpLevel":
                return new IconUpLevel();
            case "iconUsers":
                return new IconUsers();
            case "iconVideo":
                return new IconVideo();
        }
        return null;
    }

    public function new()
    {
    }
}

