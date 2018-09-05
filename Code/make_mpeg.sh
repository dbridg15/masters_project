

ffmpeg -r 20 -i ../Results/plots/frames/$1%3d.png -c:v libx264 ../Results/plots/$2.mp4

ffmpeg -i ../Results/plots/$2.mp4 ../Results/plots/$2.mpeg

