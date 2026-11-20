/// @description Muestra recursos acumulados y estadísticas del intento

//Conservar la configuración de dibujo anterior
var PreviousColor = draw_get_color();
var PreviousAlpha = draw_get_alpha();
var PreviousHAlign = draw_get_halign();
var PreviousVAlign = draw_get_valign();

var GuiWidth = display_get_gui_width();

var Margin = 8;
var StartY = 26;
var LineHeight = 18;

draw_set_color(c_white);
draw_set_alpha(1);
draw_set_valign(fa_top);

//Recursos acumulados a la izquierda
draw_set_halign(fa_left);

draw_text(Margin, StartY, "TOTAL");

draw_text(
    Margin,
    StartY + LineHeight,
    "Score: " + string(Score)
);

draw_text(
    Margin,
    StartY + LineHeight * 2,
    "Coins: " + string(Coins)
);

draw_text(
    Margin,
    StartY + LineHeight * 3,
    "Diamonds: " + string(Diamonds)
);

draw_text(
    Margin,
    StartY + LineHeight * 4,
    "Lives: " + string(Lives)
);

//Estadísticas del intento a la derecha
draw_set_halign(fa_right);

var RightX = GuiWidth - Margin;

draw_text(RightX, StartY, "INTENTO");

draw_text(
    RightX,
    StartY + LineHeight,
    "Score: " + string(LevelScore)
);

draw_text(
    RightX,
    StartY + LineHeight * 2,
    "Coins: " + string(LevelCoins)
);

draw_text(
    RightX,
    StartY + LineHeight * 3,
    "Diamonds: " + string(LevelDiamonds)
);

//Restaurar la configuración de dibujo
draw_set_color(PreviousColor);
draw_set_alpha(PreviousAlpha);
draw_set_halign(PreviousHAlign);
draw_set_valign(PreviousVAlign);