velLeft=math.pi/4 -- Velocidad para la rueda izquierda
velRight=math.pi/4 -- Velocidad para la rueda derecha
s_ant_izq=1 -- Fuera de la línea
s_ant_der=1 -- Fuera de la línea
giro=0 -- Derecha
pinzas=1 -- Brazos arriba
simExtK3_setGripperGap(170) -- Dedos abiertos
simExtK3_setArmPosition(300) -- Brazos arriba para que los sensores tengan visibilidad
esquivar=0 -- Control de esquivación de objetos grandes
mov=1 -- Contador de número de movimientos para evitar obstáculo grande

while (1) do
	
--LINEA------------------------------------------------------------------------------------------------------------	

	-- Todo lo que sea inferior o igual a 0'95 será considerado como negro (0)
	-- para ambos sensores
	s_act_izq=simExtK3_getLineSensor(1)
	if (s_act_izq<=0.95) then
		s_act_izq=0
	else
		s_act_izq=1
	end

	s_act_der=simExtK3_getLineSensor(0)
	if (s_act_der<=0.95) then
		s_act_der=0
	else
		s_act_der=1
	end	

	-- Si actualmente está en suelo negro y los brazos están arriba, sigue recto
	if(s_act_izq==0)and(s_act_der==0) and (pinzas==1) then
		simExtK3_setVelocity(velLeft,velRight)
		-- Recarga las posiciones anteriores, que son las actuales para tener un 
		-- historial de dónde ha estado la última vez y así poder realizar los
		-- giros pertinentes
		s_ant_izq=s_act_izq
		s_ant_der=s_act_der
	    
		-- En caso de que sea necesario reiniciar el contador. Siempre que mov=1,
        -- significa que no tiene que evitar ningún obstáculo grande	
		mov=1
	end

	-- Si se sale por la izquierda, tiene las pinzas arriba y no está realizando 
	-- movimientos de esquivar, gira a la derecha 15º
	if(s_act_izq==1 and s_act_der==0) and (mov==1) and (pinzas==1) then
		simExtK3_setVelocity(velLeft/2,-velRight/2)
		simWait((4/3)/9)
		simWait(1/15)

		s_ant_der=s_act_der

		giro=0
	end

		
	-- Si se sale por la derecha, tiene las pinzas arriba y no está realizando 
	-- movimientos de esquivar, gira a la izquierda 15º
	if(s_act_izq==0 and s_act_der==1) and (mov==1) and (pinzas==1) then
		-- si me salgo por la derecha
		-- giro a la izquierda 15º
		simExtK3_setVelocity(-velLeft/2,velRight/2)
		simWait((4/3)/9)
		simWait(1/15)

		s_ant_izq=s_act_izq
		giro=1 -- porque he girado a izquierda
	end

	-- Si se sale por los dos lados a la vez y anteriormente estuvo sobre la 
	-- línea, deberá hacer unos giros más bruscos
	if(s_act_izq==1 and s_act_der==1) and (mov==1) and (pinzas==1) then
		-- Si el último giro fue a la derecha, gira 45º a la izquierda	
		if (giro==0) then
			simExtK3_setVelocity(-velLeft/2,velRight/2)
			simWait((4/3)/2)
			simWait(1/15)
		 
			-- Al girar a la izquierda, es como si se hubiese salido por la derecha,
			-- entonces para que siga el giro a izquierda, se le establecen estos 
			-- parámetros para que entre en la condición de giro a izquierda y siga
			-- girando en esa misma dirección
			s_act_izq=0
			s_act_der=1
		
			-- Así se obliga a que vuelva a entrar aqui para seguir girando a la izquierda
			-- ya que los giros de 15º en ocasiones son insuficientes para salir del bloqueo
			giro=0
		
		-- Si el último giro fue a la izquierda, gira 45º a la derecha
		else
			simExtK3_setVelocity(velLeft/2,-velRight/2)
			simWait((4/3)/2)
			simWait(1/15)

			s_act_izq=1
			s_act_der=0
			
			giro=1
		end
	end	


-------------------------------------------------------------------------------------------------------------------	
	
	-- Estas funciones obtienen el valor de las distancias en metros
	sensor0=simExtK3_getInfrared(0) -- sensor trasero izquierdo (vista superior)
	sensor1=simExtK3_getInfrared(1) -- sensor lateral izquierdo (vista superior)
	sensor2=simExtK3_getInfrared(2) -- sensor diagonal izquierdo (vista superior)
	sensor3=simExtK3_getInfrared(3) -- sensor frontal izquierdo (vista superior)
	sensor4=simExtK3_getInfrared(4) -- sensor frontal derecho (vista superior)
	sensor5=simExtK3_getInfrared(5) -- sensor diagonal derecho (vista superior)
	sensor6=simExtK3_getInfrared(6) -- sensor lateral derecho (vista superior)
	
	-- Contador para saber cuántos sensores están detectando
	numero_sensores=0

	-- El contador se va incrementando si alguno de los 2 frontales o los 2 diagonales
	-- realiza alguna detección
	if (sensor2<0.1) then
		numero_sensores= numero_sensores+1
	end
	
	if (sensor3<0.04) then
		numero_sensores= numero_sensores+1
	end

	if (sensor4<0.04) then
		numero_sensores= numero_sensores+1
	end

	if (sensor5<0.1) then
		numero_sensores= numero_sensores+1
	end

	if (numero_sensores>2) then
		esquivar=1
	end


--COGER------------------------------------------------------------------------------------------------------------	
	-- Si el contador se sensores es menor o igual a 2, significa que el obstáculo es pequeño, por tanto, hay que cogerlo
	-- Tambien hay que comprobar si no se ha realizado ningún movimiento de esquivar o de coger
	if (numero_sensores<=2) and (s_act_izq==0 and s_act_der==0) 
		and (((sensor3<0.04 or sensor4<0.04 or sensor2<0.04 or sensor5<0.04) and (mov==1)) or (pinzas==0)) then

		
		-- Si detecta algo con los sensores frontales, nada con los diagonales y tiene los brazos subidos
		if (sensor3<=0.04 and sensor4<=0.04) and (sensor2>=0.1 and sensor5>=0.1) and (pinzas==1) then      
			simExtK3_setVelocity(-velLeft,-velRight) -- retrocede
			simWait(1/100)
			simExtK3_setArmPosition(900) -- baja los brazos
			simWait(2)
			
			simExtK3_setVelocity(velLeft,velRight) -- avanza

			-- Indica con la variable booleana que las pinzas están bajadas
			pinzas=0
		end

		-- Si detecta algo solo con el sensor frontal izquierdo, gira muy ligeramente hacia la izquierda
		if (sensor3<=0.04) and (sensor4>=0.05 and sensor2>=0.05 and sensor5>0.05) and (pinzas==1) then
			simExtK3_setVelocity(-velLeft/2,velRight/2) -- giro a la izquierda
			simWait((4/3)/15)
			simWait(1/15)

			simExtK3_setVelocity(-velLeft,-velRight) -- retrocede
			simWait(1/100)
			simExtK3_setArmPosition(900) -- baja los brazos
			simWait(2)
			
			simExtK3_setVelocity(velLeft,velRight) -- avanza

			pinzas=0
		end
		
		-- Si detecta algo solo con el sensor frontal derecho, gira muy ligeramente hacia la derecha
		if (sensor4<=0.04) and (sensor3>=0.05 and sensor5>=0.05 and sensor2>0.05) and (pinzas==1) then
			simExtK3_setVelocity(velLeft/2,-velRight/2) -- giro a la derecha
			simWait((4/3)/15)
			simWait(1/15)

			simExtK3_setVelocity(-velLeft,-velRight) -- retrocede
			simWait(1/100)
			simExtK3_setArmPosition(900) -- baja los brazos
			simWait(2)
			
			simExtK3_setVelocity(velLeft,velRight) -- avanza

			pinzas=0
		end

		
		-- Si detecta algo con los sensores frontal y diagonal izquierdo, gira ligeramente hacia la izquierda
		if (sensor3<=0.02 and sensor2<=0.05) and ((sensor4>=0.15) or (sensor5>=0.15)) and (sensor1>=0.15) and (pinzas==1) then
			simExtK3_setVelocity(-velLeft/2,velRight/2) -- giro a la izquierda 15 grados
			simWait((4/3)/8)
			simWait(1/15)

			simExtK3_setVelocity(-velLeft,-velRight) -- retrocede
			simWait(1/100)
			simExtK3_setArmPosition(900) -- baja los brazos
			simWait(2)
			
			simExtK3_setVelocity(velLeft,velRight) -- avanza

			pinzas=0

		end
		
		-- Si detecta algo con los sensores frontal y diagonal derecho, gira ligeramente hacia la derecha
		if (sensor4<=0.02 and sensor5<=0.05) and ((sensor2>=0.15) or (sensor3>=0.15)) and (sensor6>=0.15) and (pinzas==1) then
			simExtK3_setVelocity(velLeft/2,-velRight/2) -- giro a la derecha 15 grados
			simWait((4/3)/8)
			simWait(1/15)

			simExtK3_setVelocity(-velLeft,-velRight) -- retrocede
			simWait(1/100)
			simExtK3_setArmPosition(900) -- baja los brazos
			simWait(2)
			
			simExtK3_setVelocity(velLeft,velRight) -- avanza

			pinzas=0
		end


		-- Si detecta algo solo con el diagonal izquierdo, gira más brusco hacia la izquierda	
		if (sensor2<=0.04) and (sensor3>=0.12 and sensor4>=0.12 and sensor5>=0.12 and sensor1>=0.12) and (pinzas==1) then    
			simExtK3_setVelocity(-velLeft/2,velRight/2) -- giro a la izquierda 45 grados
			simWait((4/3)/2)
			simWait(1/15)

			simExtK3_setVelocity(-velLeft,-velRight) -- retrocede
			simWait(1/100)
			simExtK3_setArmPosition(900) -- baja los brazos
			simWait(2)

			simExtK3_setVelocity(velLeft,velRight) -- avanza

			pinzas=0
		end

		
		-- Si detecta algo solo con el diagonal derecho, gira más brusco hacia la derecha	
		if (sensor2<=0.04) and (sensor3>=0.12 and sensor4>=0.12 and sensor5>=0.12 and sensor1>=0.12) and (pinzas==1) then    
			simExtK3_setVelocity(velLeft/2,-velRight/2) -- giro a la derecha 45 grados
			simWait((4/3)/2)
			simWait(1/15)

			simExtK3_setVelocity(-velLeft,-velRight) -- retrocede
			simWait(1/100)
			simExtK3_setArmPosition(900) -- baja los brazos
			simWait(2)

			simExtK3_setVelocity(velLeft,velRight) -- avanza

			pinzas=0
		end

		-- Estas funciones obtienen el valor de las distancias obtenidas por las pinzas
		pinza_derecha=simExtK3_getGripperProxSensor(1)
		pinza_izquierda=simExtK3_getGripperProxSensor(0)
		
		-- Si las pinzas detectan algún objeto y están bajadas		
		if (pinza_izquierda>200 or pinza_derecha>200) and (pinzas==0) then
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
			
			-- Se inicializan las variables a 0
			mov=0
			giro=0
		end
		
	end

	
--ESQUIVAR------------------------------------------------------------------------------------------------------------		
	
	-- Si el contador se sensores es mayor que 2, significa que el obstáculo es grande, por tanto, hay que esquivarlo
	-- Hay que comprobar si los sensores diagonales detectan algo y si los sensores lateral y diagonal izquierdo detectan 
	-- algo mientras que los frontales no detecten nada (para cuando esté realizando los movimientos de esquivar)
	if (((sensor3<0.04) and (sensor4<0.04) and (((sensor2>0.04) or (sensor5>0.04)) and ((sensor2<0.15) or (sensor5<0.15)))) 
		or ((sensor3>0.1) and (sensor4>0.1) and ((sensor1<0.05) or (sensor0<0.1))) 
		and (mov>=1) and (pinzas==1) and (numero_sensores>2)) 
		or (esquivar==1) then
	
		-- Si detecta algo por los sensores frontales
		if (sensor3<0.04 and sensor4<0.04) and (mov==1) then
			-- Se incrementa el contador de movimientos porque va a realizar un giro de 90º hacia la
            -- derecha para evitar el obstáculo grande
			mov=2
			simExtK3_setVelocity(velLeft/2,-velRight/2) -- giro 90º a la derecha
			simWait(4/3)
			giro=0 -- porque ha girado a derecha
			simWait(1/15)
			
			s_ant_izq=s_act_izq
			s_ant_der=s_act_der

			simExtK3_setVelocity(velLeft,velRight) -- avance
			simWait(1/4)

		end


		-- Cuando todos los sensores del lateral izquierdo se alejen demasiado del obstáculo, deberán
		-- volver a acercarse muy muy ligeramente para no perder la detección
		if (sensor0>0.06 and sensor1>0.1 and sensor2>0.1) and (mov>=2) then
			simExtK3_setVelocity(-velLeft/2,velRight/2) -- giro a la izquierda
			simWait(4/3/2/3/2/2)
		end



		-- Cuando todos los sensores del lateral izquierdo dejen de detectar algo, 
		-- entonces deberá hacer un giro de 90º hacia la izquierda. Hay que comprobar 
		-- también que esté en la fase 2 del movimiento
		if(sensor1>0.15) and (sensor0>0.15) and (mov==2) then
            -- Se incrementa el contador de movimientos
			mov=3
			simExtK3_setVelocity(-velLeft/2,velRight/2) -- giro 90º a la izquierda
			simWait(4/3)
			giro=1 -- porque ha girado a izquierda
			simWait(1/15)

			s_ant_izq=s_act_izq
			s_ant_der=s_act_der
		end


		-- Se aumentan un poquito las distancias permitidas por los errores de giro que va llevando desde el principio
		-- Cuando los 3 sensores del lateral izquierdo no detecten el obstáculo a una distancia relativamente cerca,
		-- significa que está lo suficientemente lejos como para poder girar 90º sin molestarle el objeto. Hay que 
		-- comprobar también que esté en la fase 3 del movimiento		
		if(sensor2>0.1 and sensor1>0.15 and sensor0>0.05) and (mov==3) then
			-- Como es el último movimiento de esquive, se reinicia el contador
			mov=0
			esquivar=0
			simExtK3_setVelocity(-velLeft/2,velRight/2) -- giro 90º a la izquierda
			simWait(4/3)
			giro=1 -- porque ha girado a izquierda
			simWait(1/15)

			s_ant_izq=s_act_izq
			s_ant_der=s_act_der
		end


		-- Una vez que se ha terminado de evitar el obstáculo, se vuelve a realizar una lectura de los valores del suelo
		s_act_izq=simExtK3_getLineSensor(1)
		if (s_act_izq<=0.94) then
			s_act_izq=0
		else
			s_act_izq=1
		end

		s_act_der=simExtK3_getLineSensor(0)
		if (s_act_der<=0.94) then
			s_act_der=0
		else
			s_act_der=1
		end

		-- También hay que tener en cuenta la posibilidad de que un objeto grande se encuentre en una esquina de la línea,
		-- en este caso, no habría que realizar los 3 movimientos comentados anteriormente y con estas líneas se soluciona
		if (s_act_izq==0) and (s_act_der==0) and (mov>1) then
			mov=0
			esquivar=0
			simExtK3_setVelocity(velLeft/2,-velRight/2) -- giro 15º a la derecha
			simWait(4/3/2/3)		
		end

	end
		
		
	simExtK3_setVelocity(velLeft,velRight)
	
end