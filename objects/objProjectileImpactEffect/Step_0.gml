/// @description Reproduce el impacto y lo elimina al terminar

var Duration = max(
    1,
    floor(DurationFrames)
);

if (EffectTimer >= Duration)
{
    instance_destroy();
    exit;
}

if (sprite_index != -1)
{
    var FrameCount = max(
        1,
        sprite_get_number(sprite_index)
    );

    image_index = min(
        FrameCount - 1,
        floor(
            EffectTimer
            * FrameCount
            / Duration
        )
    );
}

EffectTimer += 1;