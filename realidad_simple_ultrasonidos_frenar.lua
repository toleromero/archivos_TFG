velLeft=math.pi/4 -- Velocidad para la rueda izquierda
velRight=math.pi/4 -- Velocidad para la rueda derecha
pared=0 -- Variable booleana para indicar que no hay pared

while (1) do

	ultra_sensor1=simExtK3_getUltrasonic(1) -- diagonal izquierdo (vista superior)
	ultra_sensor2=simExtK3_getUltrasonic(2) -- frontal (vista superior)
	ultra_sensor3=simExtK3_getUltrasonic(3) -- diagonal derecho (vista superior)
	
	-- Si el sensor ultrasónico no detecta nada con el sensor frontal, avanza muy rápido
	if (ultra_sensor2>0.3) and (pared==0) then
		simExtK3_setVelocity(velLeft*6,velRight*6)
	
	-- Si los sensores diaogonales detecta algo, para en seco
	elseif (ultra_sensor1<0.3 and ultra_sensor3<0.3) then
		simExtK3_setVelocity(0,0)
		-- Indica que ya ha encontrado la pared
		pared=1
	end
	
end