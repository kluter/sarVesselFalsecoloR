pwlCol <- c("#2b83ba", "#3087b9", "#358ab8", "#3a8eb8", "#4092b7",
            "#4595b6", "#4a99b5", "#4f9db4", "#55a1b3", "#55a1b3",
            "#5fa8b1", "#64acb0", "#6aafaf", "#6fb3af", "#74b7ae",
            "#79baad", "#7fbeac", "#84c2ab", "#89c5aa", "#8ec9a9",
            "#94cda8", "#99d0a7", "#9ed4a6", "#a3d8a5", "#a9dca5",
            "#addea5", "#b0dfa6", "#b4e1a7", "#b7e2a8", "#bbe4a9",
            "#bee5aa", "#c2e6ab", "#c5e8ac", "#c8e9ae", "#ccebaf",
            "#cfecb0", "#d3edb1", "#d6efb2", "#daf0b3", "#ddf2b4",
            "#e1f3b5", "#e4f4b6", "#e7f6b8", "#ebf7b9", "#eef9ba",
            "#f2fabb", "#f5fbbc", "#f9fdbd", "#fcfebe", "#ffffbf",
            "#fffcbb", "#fff9b8", "#fff6b4", "#fff2b0", "#ffefac",
            "#ffeca8", "#ffe8a4", "#ffe5a0", "#ffe29d", "#ffde99",
            "#ffdb95", "#ffd891", "#fed48d", "#fed189", "#fece85",
            "#feca82", "#fec77e", "#fec47a", "#fec076", "#febd72",
            "#feba6e", "#feb66b", "#feb367", "#feb063", "#fdab5f",
            "#fba55d", "#fa9f5a", "#f89957", "#f69354", "#f58d51",
            "#f3864f", "#f2804c", "#f07a49", "#ef7446", "#ed6e43",
            "#ec6840", "#ea623e", "#e85c3b", "#e75638", "#e55035",
            "#e44932", "#e2432f", "#e13d2d", "#df372a", "#de3127",
            "#dc2b24", "#da2521", "#d91f1e", "#d7191c", "#d7191c"
            )



p <- expand.grid(x=1:256,y=1:256)
p$z <- p$x + p$y
coordinates(p) <- c("x", "y")
gridded(p) <- TRUE
test <- image(p, col = pwlCol, asp = 1)
# require(lattice)
# trellis.par.set("regions", list(col=bpy.colors())) # make this default pallette
plot(test)


colorRampPalette(colors = pwlCol)
