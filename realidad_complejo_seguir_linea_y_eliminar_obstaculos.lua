velLeft=math.pi/4 -- Velocidad para la rueda izquierda
velRight=math.pi/4 -- Velocidad para la rueda derecha
s_ant_izq=1 -- Fuera de la línea
s_ant_der=1 -- Fuera de la línea
giro=0 -- Derecha
pinzas=1 -- Brazos arriba
coger=0 -- Control de cogida de objetos
simExtK3_setGripperGap(170) -- Dedos abiertos
simExtK3_setArmPosition(300) -- Brazos arriba para que los sensores tengan visibilidad

while (1) do

	-- Todo lo que sea inferior o igual a 0'9 será considerado como negro (0)
	-- para ambos sensores
	s_act_izq=simExtK3_getLineSensor(1)
	if (s_act_izq<=0.9) then
		s_act_izq=0
	else
		s_act_izq=1
	end

	s_act_der=simExtK3_getLineSensor(0)
	if (s_act_der<=0.9) then
		s_act_der=0
	else
		s_act_der=1
	end	

	-- Si actualmente está en suelo negro y los brazos están arriba, sigue recto
	if (s_act_izq==0)and(s_act_der==0) and (pinzas==1) and (coger==0) then
		simExtK3_setVelocity(velLeft,velRight)
		-- Recarga las posiciones anteriores, que son las actuales para tener un 
		-- historial de dónde ha estado la última vez y así poder realizar los
		-- giros pertinentes
		s_ant_izq=s_act_izq
		s_ant_der=s_act_der
	end

	-- Si se sale por la izquierda y anteriormente estuvo sobre la línea, gira
	-- a la derecha 15º
	if (s_act_izq==1 and s_act_der==0) and (s_ant_izq==0 and s_ant_der==0) and (pinzas==1) and (coger==0) then       
		simExtK3_setVelocity(velLeft/2,-velRight/2)
		simWait((4/3)/9)
		simWait(1/15)
		
		-- Solo hay que recargar el sensor derecho, ya que el izquierdo ha estado
		-- fuera de la línea
		s_ant_der=s_act_der
		
		-- Variable booleana para comprobar la dirección de los giros: 0 indica
		-- giro a derecha, 1 indica giro a izquierda
		giro=0
	end

	-- Si se sale por la derecha y anteriormente estuvo sobre la línea, gira
	-- a la izquierda 15º
	if (s_act_izq==0 and s_act_der==1) and (s_ant_izq==0 and s_ant_der==0) and (pinzas==1) and (coger==0) then       
		simExtK3_setVelocity(-velLeft/2,velRight/2)
		simWait((4/3)/9)
		simWait(1/15)
		
		-- Solo hay que recargar el sensor izquierdo, ya que el derecho ha estado
		-- fuera de la línea
		s_ant_izq=s_act_izq
		
		giro=1
	end

   
	-- Si se sale por los dos lados a la vez y anteriormente estuvo sobre la 
	-- línea, deberá hacer unos giros más bruscos
	if (s_act_izq==1 and s_act_der==1) and (s_ant_izq==0 and s_ant_der==0) and (pinzas==1) and (coger==0) then    
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


	
	sensor2=simExtK3_getInfrared(2) -- sensor diagonal izquierdo (vista superior)
	sensor3=simExtK3_getInfrared(3) -- sensor frontal izquierdo (vista superior)
	sensor4=simExtK3_getInfrared(4) -- sensor frontal derecho (vista superior)
	sensor5=simExtK3_getInfrared(5) -- sensor diagonal derecho (vista superior)

	
	-- Si detecta algo con los sensores frontales y tiene los brazos subidos
	if (sensor3<=0.04 and sensor4<=0.04) and (pinzas==1) then      
		simExtK3_setVelocity(-velLeft,-velRight) -- retrocede
		simWait(1/100)
		simExtK3_setArmPosition(900) -- baja los brazos
		simWait(2)
		
		simExtK3_setVelocity(velLeft,velRight) -- avanza

		-- Indica con la variable booleana que las pinzas están bajadas
		pinzas=0
		
		-- Indica con la variable booleana que se está iniciando el movimiento de coger
		coger=1
	end
	
	-- Si detecta algo solo con el sensor frontal izquierdo, gira muy ligeramente hacia la izquierda
	if (sensor3<=0.04 and sensor4>=0.05 and sensor2>=0.05) and (pinzas==1) and (coger==0) then
		simExtK3_setVelocity(-velLeft/2,velRight/2)
		simWait((4/3)/15)
		simWait(1/15)

		simExtK3_setVelocity(-velLeft,-velRight) -- retrocede
		simWait(1/100)
		simExtK3_setArmPosition(900) -- baja los brazos
		simWait(2)
		
		simExtK3_setVelocity(velLeft,velRight) -- avanza

		pinzas=0
		
		coger=1
	end

	-- Si detecta algo solo con el sensor frontal derecho, gira muy ligeramente hacia la derecha
	if (sensor4<=0.04 and sensor3>=0.05 and sensor5>=0.05) and (pinzas==1) and (coger==0)then       
		simExtK3_setVelocity(velLeft/2,-velRight/2) -- giro a la derecha muy muy poquito
		simWait((4/3)/15)
		simWait(1/15)

		simExtK3_setVelocity(-velLeft,-velRight) -- retrocede
		simWait(1/100)
		simExtK3_setArmPosition(900) -- baja los brazos
		simWait(2)
		
		simExtK3_setVelocity(velLeft,velRight) -- avanza

		pinzas=0
		
		coger=1
	end
	
	-- Si detecta algo con los sensores frontal y diagonal izquierdo, gira ligeramente hacia la izquierda
	if (sensor3<=0.02 and sensor2<=0.05) and (pinzas==1) and (coger==0) then      
		simExtK3_setVelocity(-velLeft/2,velRight/2) -- giro a la izquierda 15 grados
		simWait((4/3)/12)
	    simWait(1/15)

		simExtK3_setVelocity(-velLeft,-velRight) -- retrocede
		simWait(1/100)
		simExtK3_setArmPosition(900) -- baja los brazos
		simWait(2)
		
		simExtK3_setVelocity(velLeft,velRight) -- avanza

		pinzas=0
		
		coger=1
	end

	-- Si detecta algo con los sensores frontal y diagonal derecho, gira ligeramente hacia la derecha
	if (sensor4<=0.02 and sensor5<=0.05) and (pinzas==1) and (coger==0) then    

		simExtK3_setVelocity(velLeft/2,-velRight/2) -- giro a la derecha 15 grados
		simWait((4/3)/12)
		simWait(1/15)

 		simExtK3_setVelocity(-velLeft,-velRight) -- retrocede
		simWait(1/100)
		simExtK3_setArmPosition(900) -- baja los brazos
		simWait(2)
		
		simExtK3_setVelocity(velLeft,velRight) -- avanza

		pinzas=0
		
		coger=1
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
		
		-- Se avisa de que el movimiento de coger ha terminado
		coger=0
	end
	
    simExtK3_setVelocity(velLeft,velRight) -- avance

end