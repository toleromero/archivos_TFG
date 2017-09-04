velLeft=math.pi/4 -- Velocidad para la rueda izquierda
velRight=math.pi/4 -- Velocidad para la rueda derecha
pinzas=1 -- Brazos arriba
simExtK3_setArmPosition(300) -- Brazos arriba para que los sensores tengan visibilidad
simExtK3_setGripperGap(170) -- Dedos abiertos

while (1) do

	-- Estas funciones obtienen el valor de las distancias en metros
	sensor3=simExtK3_getInfrared(3) -- sensor frontal izquierdo (vista superior)
	sensor4=simExtK3_getInfrared(4) -- sensor frontal derecho (vista superior)

	
	-- Si detecta algo con los sensores frontales y tiene los brazos subidos
	 if (sensor3<=0.04 and sensor4<=0.04) and (pinzas==1) then      
		simExtK3_setVelocity(-velLeft,-velRight) -- retrocede
		simWait(1/100)
		simExtK3_setArmPosition(900) -- baja los brazos
		simWait(2)
		
		simExtK3_setVelocity(velLeft,velRight) -- avanza

		-- Indica con la variable booleana que las pinzas están bajadas
		pinzas=0
	end

	
	-- Estas funciones obtienen el valor de las distancias obtenidas por las pinzas
	pinza_derecha=simExtK3_getGripperProxSensor(1)
	pinza_izquierda=simExtK3_getGripperProxSensor(0)
	
	-- Si las pinzas detectan algún objeto y están bajadas		
	if (pinza_izquierda>400 or pinza_derecha>400) and (pinzas==0) then
		-- Stop para que pare a coger el objeto
		simExtK3_setVelocity(0,0)

		
		simExtK3_setGripperGap(0) -- cierra los dedos para agarrar el objeto
		simWait(1)
		simWait(1/15)

		simExtK3_setArmPosition(300) -- sube los brazos para que nada le moleste el giro
		simWait(2)
		simWait(1/15)

		simExtK3_setVelocity(velLeft/2,-velRight/2) -- giro de 90º a la derecha
		simWait(4/3)
		
		-- Stop para que pare a dejar el objeto
		simExtK3_setVelocity(0,0)

		simExtK3_setArmPosition(900) -- baja los brazos para dejar el objeto
		simWait(2)
		simWait(1/15)

		simExtK3_setGripperGap(170) -- abre los dedos para soltar el objeto
		simWait(1)
		simWait(1/15)

		simExtK3_setArmPosition(300) -- sube los brazos para que nada le moleste en el giro
		simWait(2)
		simWait(1/15)

		simExtK3_setVelocity(-velLeft/2,velRight/2) -- giro de 90º a la izquierda
		simWait(4/3)	

		simExtK3_setVelocity(velLeft,velRight) -- avance
		simWait(1)

		-- Se avisa de que las pinzas vuelven a estar arriba
		pinzas=1
	end	

	simExtK3_setVelocity(velLeft,velRight) -- avance

end