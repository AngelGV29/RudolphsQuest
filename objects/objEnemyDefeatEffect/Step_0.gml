/// @description Reproduce el efecto y lo elimina al terminar

var Duration = max(1, DurationFrames);

//Eliminar el efecto al terminar su duración
if (EffectTimer >= Duration)
{
    instance_destroy();
    exit;
}

//Distribuir los fotogramas a lo largo de la duración
if (sprite_index != -1)
{
    var FrameCount = sprite_get_number(sprite_index);

    if (FrameCount > 0)
    {
        image_index = min(
            FrameCount - 1,
            floor(EffectTimer * FrameCount / Duration)
        );
    }
}

EffectTimer += 1;