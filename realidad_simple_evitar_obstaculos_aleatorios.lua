velLeft=math.pi/4 -- Velocidad para la rueda izquierda
velRight=math.pi/4 -- Velocidad para la rueda derecha
	
while (1) do

	-- Estas funciones obtienen el valor de las distancias en metros para cada uno de los 9 sensores que tiene el robot
	sensor0=simExtK3_getInfrared(0) -- sensor trasero izquierdo (vista superior)
	sensor1=simExtK3_getInfrared(1) -- sensor lateral izquierdo (vista superior)
	sensor2=simExtK3_getInfrared(2) -- sensor diagonal izquierdo (vista superior)
	sensor3=simExtK3_getInfrared(3) -- sensor frontal izquierdo (vista superior)
	sensor4=simExtK3_getInfrared(4) -- sensor frontal derecho (vista superior)
	sensor5=simExtK3_getInfrared(5) -- sensor diagonal derecho (vista superior)
	sensor6=simExtK3_getInfrared(6) -- sensor lateral derecho (vista superior)
	sensor7=simExtK3_getInfrared(7) -- sensor trasero derecho (vista superior)
	sensor8=simExtK3_getInfrared(8) -- sensor trasero frontal (vista superior)
	
	-- Estas son las distancias mínimas permitidas, es decir, 1 cm para cualquiera de los sensores
	dist_min_frontal=0.05
	dist_min_diagonal=0.05
	dist_min_lateral=0.04
	
	-- Si los valores de los sensores frontales son mayores que la distancia mínima 
    -- frontal establecida, sigue su camino recto porque no detecta obstáculo
	if (sensor3>dist_min_frontal) and (sensor4>dist_min_frontal) then
		simExtK3_setVelocity(velLeft,velRight)
        
	-- Si los sensores frontales han detectado obstáculo...
	else
		-- Si los valores de los derechos (diagonal y lateral) son mayores que los 
        -- valores de los sensores izquierdos, el robot detecta obstáculo por la derecha		
		if (sensor2>sensor5) and (sensor1>sensor6) then
			-- Gira hacia la izquierda de 20º
			simExtK3_setVelocity(-velLeft/2,velRight/2)
			simWait((4/3)/4.5)
			simWait(1/20)
		
        -- Si, por el contrario, son mayores los valores de los sensores izquierdos, 
        -- el robot detecta el obstáculo por la izquierda
		else
			-- Gira hacia la derecha de 20º
			simExtK3_setVelocity(velLeft/2,-velRight/2)
			simWait((4/3)/4.5)
			simWait(1/20)
		end

	end

	-- Si el valor del sensor diagonal derecho es menor que la distancia mínima 
	-- diagonal establecida, hay que girar
	if (sensor2<dist_min_diagonal) then
		-- Se realiza un giro hacia la derecha de 20º porque el robot detecta un obstáculo 
		-- por el lateral izquierdo
		simExtK3_setVelocity(velLeft/2,-velRight/2)
		simWait((4/3)/4.5)
		simWait(1/20)
	end
	
	-- Si el valor del sensor diagonal izquierdo es menor que la distancia mínima 
	-- diagonal establecida, hay que girar
	if (sensor5<dist_min_diagonal) then
		-- Se realiza un giro hacia la izquierda de 20º porque el robot detecta un 
		-- obstáculo por el lateral derecho
		simExtK3_setVelocity(-velLeft/2,velRight/2)
		simWait((4/3)/4.5)
		simWait(1/20)
	end
	
	-- Si el valor del sensor lateral derecho es menor que la distancia mínima lateral 
    -- establecida, hay que girar
	if (sensor1<dist_min_lateral) then
		-- Se realiza un giro hacia la derecha de 20º porque el robot detecta un 
		-- obstáculo por el lateral izquierdo
		simExtK3_setVelocity(velLeft/2,-velRight/2)
		simWait((4/3)/4.5)
		simWait(1/20)
	end
	
	-- Si el valor del sensor lateral izquierdo es menor que la distancia mínima lateral 
	-- establecida, hay que girar
	if (sensor6<dist_min_lateral) then
		-- Se realiza un giro hacia la izquierda de 20º porque el robot detecta un 
		-- obstáculo por el lateral derecho
		simExtK3_setVelocity(-velLeft/2,velRight/2)
		simWait((4/3)/4.5)
		simWait(1/20)
	end

	-- Si el valor de los seis sensores frontales es inferior a la distancia minima frontal
	-- y el valor de los traseros es superior a esa distancia, quiere decir que se ha quedado
	-- encerrado y tiene quedar la media vuelta
	if (sensor3<dist_min_frontal and sensor4<dist_min_frontal and sensor1<dist_min_lateral and sensor6<dist_min_lateral) then
        -- Giro a la izquierda, por ejemplo, de 20º
		simExtK3_setVelocity(-velLeft/2,velRight/2)
		simWait((4/3)/4.5)
		simWait(1/20)
	end

end