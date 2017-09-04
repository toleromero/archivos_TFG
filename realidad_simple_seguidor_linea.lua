velLeft=math.pi/4 -- Velocidad para la rueda izquierda
velRight=math.pi/4 -- Velocidad para la rueda derecha
s_ant_izq=1 -- Fuera de la l�nea
s_ant_der=1 -- Fuera de la l�nea
giro=0 -- Derecha


while (1) do

	-- Todo lo que sea inferior o igual a 0'9 ser� considerado como negro (0)
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
	

	-- Si actualmente est� en suelo negro, sigue recto
	if(s_act_izq==0 and s_act_der==0) then
		simExtK3_setVelocity(velLeft,velRight)
		-- Recarga las posiciones anteriores, que son las actuales para tener un 
		-- historial de d�nde ha estado la �ltima vez y as� poder realizar los
		-- giros pertinentes
		s_ant_izq=s_act_izq
		s_ant_der=s_act_der
	end

	-- Si se sale por la izquierda y anteriormente estuvo sobre la l�nea, gira
	-- a la derecha 15�
	if(s_act_izq==1 and s_act_der==0) and (s_ant_izq==0 and s_ant_der==0) then
		simExtK3_setVelocity(velLeft/2,-velRight/2)
		simWait((4/3)/9)
		simWait(1/15)
		
		-- Solo hay que recargar el sensor derecho, ya que el izquierdo ha estado
		-- fuera de la l�nea
		s_ant_der=s_act_der

		-- Variable booleana para comprobar la direcci�n de los giros: 0 indica
		-- giro a derecha, 1 indica giro a izquierda
		giro=0
	end	
	

    -- Si se sale por la derecha y anteriormente estuvo sobre la l�nea, gira
	-- a la izquierda 15�
	if(s_act_izq==0 and s_act_der==1) and (s_ant_izq==0 and s_ant_der==0) then
		simExtK3_setVelocity(-velLeft/2,velRight/2)
		simWait((4/3)/9)
		simWait(1/15)
		
		-- Solo hay que recargar el sensor izquierdo, ya que el derecho ha estado
		-- fuera de la l�nea 
		s_ant_izq=s_act_izq

		giro=1
	end	
	
	

	-- Si se sale por los dos lados a la vez y anteriormente estuvo sobre la 
    -- l�nea, deber� hacer unos giros m�s bruscos	
	if(s_act_izq==1 and s_act_der==1) and (s_ant_izq==0 and s_ant_der==0) then
        -- Si el �ltimo giro fue a la derecha, gira 45� a la izquierda	
		if (giro==0) then
			simExtK3_setVelocity(-velLeft/2,velRight/2)
			simWait((4/3)/2)
			simWait(1/15)
		 
			-- Al girar a la izquierda, es como si se hubiese salido por la derecha,
			-- entonces para que siga el giro a izquierda, se le establecen estos 
			-- par�metros para que entre en la condici�n de giro a izquierda y siga
			-- girando en esa misma direcci�n
			s_act_izq=0
			s_act_der=1
			
			-- As� se obliga a que vuelva a entrar aqui para seguir girando a la izquierda
			-- ya que los giros de 15� en ocasiones son insuficientes para salir del bloqueo
			giro=0
            
        -- Si el �ltimo giro fue a la izquierda, gira 45� a la derecha
		else
			simExtK3_setVelocity(velLeft/2,-velRight/2)
			simWait((4/3)/2)
			simWait(1/15)

			s_act_izq=1
			s_act_der=0
			
			giro=1
		end
	end

	simExtK3_setVelocity(velLeft,velRight)
end