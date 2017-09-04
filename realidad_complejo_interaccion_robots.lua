while (1) do

	-- Estas funciones obtienen el valor de las distancias en metros
	sensor0=simExtK3_getInfrared(0) -- sensor trasero izquierdo (vista superior)
	sensor1=simExtK3_getInfrared(1) -- sensor lateral izquierdo (vista superior)
	sensor2=simExtK3_getInfrared(2) -- sensor diagonal izquierdo (vista superior)
	sensor3=simExtK3_getInfrared(3) -- sensor frontal izquierdo (vista superior)
	sensor4=simExtK3_getInfrared(4) -- sensor frontal derecho (vista superior)
	sensor5=simExtK3_getInfrared(5) -- sensor diagonal derecho (vista superior)
	sensor6=simExtK3_getInfrared(6) -- sensor lateral derecho (vista superior)
	sensor7=simExtK3_getInfrared(7) -- sensor trasero derecho (vista superior)
	sensor8=simExtK3_getInfrared(8) -- sensor trasero frontal (vista superior)
	
    -- La probabilidad de avanzar sera de un 90%, el 10% restante serán giros
	probabilidad_movimientos=math.random(1,10)
	
	-- Velocidad establecida
	velocidad=math.pi/4

	-- Si se entra dentro de ese 10%, se gira
	if (probabilidad_movimientos==10) then
	-- La probabilidad tanto de giro a izquierda como a derecha también será de un 50%           	
		direccion_giro=math.random(1,2)

		-- El 1 se ha asignado para giros hacia izquierda, mientras que el 2 es para derecha		
		if (direccion_giro==1) then -- giro a izquierda
			velLeft=-velocidad
			velRight=velocidad
		else -- giro a derecha
			velLeft=velocidad
			velRight=-velocidad
		end
    
	-- Si la primera variable aleatoria va del 1 al 9, avanza en línea recta		
	else
		velLeft=velocidad
		velRight=velocidad
	end

	-- Si no detecta nada por ningún sensor, se mueve aleatoriamente
	if (sensor7>0.12 and sensor8>0.12 and sensor0>0.12 and sensor2>0.12 and sensor3>0.12 and sensor4>0.12 and sensor5>0.12) then

		simExtK3_setVelocity(velLeft,velRight)
		simWait(1/4)
		
	-- Si detecta algo por atrás y nada por delante, reduce un poco la velocidad de los movimientos para no perder al robot de atrás
	elseif (sensor7<0.12 or sensor8<0.12 or sensor0<0.12) and (sensor2>0.12 and sensor3>0.12 and sensor4> 0.12 and sensor5> 0.12) then
		-- Este será el robot principal, que guíe a los demas
		simExtK3_setVelocity(velLeft/2,velRight/2)
		simWait(1/4)
	end

	-- Se define la velocidad de todos los giros a realizar
	giro=math.pi/8

	-- Si alguno de los sensores detecta una distancia muy pequeña, se para en seco para evitar colisionar	
	if (sensor1<0.03 or sensor2<0.03 or sensor3<0.03 or sensor4<0.03 or sensor5<0.03 or sensor6<0.03)then
		simExtK3_setVelocity(0,0) -- stop
		simWait(0.15)
		
	else
	
	----DIAGONAL IZQUIERDA
		-- Si detecta algo con los sensores frontal y diagonal izquierdo entre (0'05, 0'1) lo sigue de manera recta
		if (sensor2<0.1 and sensor3<0.1) and (sensor2>0.05 and sensor3>0.05) then 
			simExtK3_setVelocity(giro,giro) -- avance
			simWait(0.15)
		end
		
		-- Si solo detecta con el sensor frontal izquierdo, gira hacia la derecha para detectar también con el diagonal
		if (sensor3<0.12 and sensor2>0.12) then
			simExtK3_setVelocity(giro,-giro) -- giro a la derecha
			simWait(4/3/3/2/2)
			simWait(1/15)
			simExtK3_setVelocity(giro,giro) -- avance
			simWait(0.15)
		end
		
		-- Si solo detecta con el diagonal izquierdo o el lateral izquierdo es menor que el diagonal izquierdo, gira 
		-- bruscamente hacia la izquierda para seguir al de delante desde su trasero derecho
		if (sensor2<0.12 and sensor3>0.12) or (sensor1<sensor2) then 
			simExtK3_setVelocity(giro,giro*2) -- giro a izquierda
			simWait(4/3/3/2/2)
			simWait(1/15)
			simExtK3_setVelocity(giro,giro) -- avance
			simWait(0.15)
		end

		-- Si los sensores diagonal o frontal izquierdo detectan algo y 
		-- alguno de los tres sensores traseros también detecta algo y
		-- la distancia atrás es mucho más corta que la que se detecta con delante
		-- se produce un incremento de la velocidad para no chocarse con el robot de detrás
		-- (esta situación sirve para controlar la situación de que se coloquen tres robots en fila)
		if (sensor3<0.12 or sensor2<0.12) 
			and (sensor7<0.12 or sensor8<0.12 or sensor0<0.12) 
			and (sensor0*2<sensor3 or sensor0*2<sensor2 or sensor7*2<sensor3 or sensor7*2<sensor2 or sensor8*2<sensor3 or sensor8*2<sensor2) then
			simExtK3_setVelocity(giro*1.2,giro*1.2) -- avance
			simWait(0.15)
		end
		
		-- Si la distancia del sensor lateral izquierdo es demasiado pequeña, se gira ligeramente hacia la derecha para evitar una colisión lateral
		if (sensor1<0.05) then
			simExtK3_setVelocity(giro,-giro) -- giro a la derecha
			simWait(4/3/3/2/2)
			simWait(1/15)
			simExtK3_setVelocity(giro,giro) -- avance
			simWait(0.15)
		end
		
		
	----DIAGONAL DERECHA
		-- Si detecta algo con los sensores frontal y diagonal derecho entre (0'05, 0'1) lo sigue de manera recta
		if (sensor5<0.1 and sensor4<0.1) and (sensor5>0.05 and sensor4>0.05) then 
			simExtK3_setVelocity(giro,giro) -- avance
			simWait(0.15)
		end

		-- Si solo detecta con el sensor frontal derecho, gira hacia la izquierda para detectar también con el diagonal
		if (sensor4<0.12) and (sensor5> 0.12) then
			simExtK3_setVelocity(-giro,giro) -- giro a la izquierda
			simWait(4/3/3/2/2)
			simWait(1/15)		
			simExtK3_setVelocity(giro,giro) -- avance
			simWait(0.15)
		end
		
		-- Si solo detecta con el diagonal derecho o el lateral derecho es menor que el diagonal derecho, gira 
		-- bruscamente hacia la derecha para seguir al de delante desde su trasero izquierdo
		if (sensor5<0.12 and sensor4> 0.12) or (sensor6<sensor5) then 
			simExtK3_setVelocity(giro*2,giro) -- giro a la derecha
			simWait(4/3/3/2/2)
			simWait(1/15)			
			simExtK3_setVelocity(giro,giro) -- avance
			simWait(0.15)	
		end
		
		-- Si los sensores diagonal o frontal derecho detectan algo y 
		-- alguno de los tres sensores traseros también detecta algo y
		-- la distancia atrás es mucho más corta que la que se detecta con delante
		-- se produce un incremento de la velocidad para no chocarse con el robot de detrás
		-- (esta situación sirve para controlar la situación de que se coloquen tres robots en fila)
		if (sensor4<0.12 or sensor5<0.12) 
			and (sensor7<0.12 or sensor8<0.12 or sensor0<0.12) 
			and (sensor0*2<sensor4 or sensor0*2<sensor5 or sensor7*2<sensor4 or sensor7*2<sensor5 or sensor8*2<sensor4 or sensor8*2<sensor5) then
			simExtK3_setVelocity(giro*1.2,giro*1.2) -- avance
			simWait(0.15)
		end
		
		-- Si la distancia del sensor lateral derecho es demasiado pequeña, se gira ligeramente hacia la izquierda para evitar una colisión lateral		
		if (sensor6<0.05) then
			simExtK3_setVelocity(-giro,giro) -- giro a la izquierda
			simWait(4/3/3/2/2)
			simWait(1/15)
			simExtK3_setVelocity(giro,giro) -- avance
			simWait(0.15)
		end
	end		
end
