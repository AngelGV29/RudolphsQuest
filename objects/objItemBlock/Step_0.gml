/// @description Actualiza la activación del bloque

if (BlockState != BLOCK_STATE.ACTIVE)
{
    exit;
}

var Duration = max(1, floor(ActiveFrames));
var FrameCount = max(1, sprite_get_number(sprite_index));

var Frame = min(
    FrameCount - 1,
    floor(ActiveTimer * FrameCount / Duration)
);

image_index = Frame;

var TriggerFrame = clamp(
    floor(ReleaseFrame),
    0,
    FrameCount - 1
);

//Ejecutar una sola vez aunque se salten fotogramas
if (!EffectReleased && Frame >= TriggerFrame)
{
    EffectReleased = true;

    ReleaseContent();
    BumpEnemies();
}

ActiveTimer += 1;

//Volver al aspecto normal o agotado
if (ActiveTimer >= Duration)
{
    SetRestSprite();
}