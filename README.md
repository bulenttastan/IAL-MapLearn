IAL-MapLearn
------------


1. Create the map object using the map image and call display to show the map on the figure

   ```matlab
m = ImageMap('maps/map1.png');  
m.display();
```


2. Create the UserData object and call collect_data to start constructing the path by clicking on the map

   ```matlab
data = UserData(m);  
data.collect_data();
```