<html>
	<body>
		<h1> Welcome to server {{ http_host }}! </h1>
		
		<?php
		$server = "{{db_server}}";
		$database = "oudijkdb";
		$username = "oudijk";
		$password = "oudijk";

		$conn = mysqli_connect($server, $username, $password, $database);

		if(!$conn){
			die("Something went wrong.. Here's the error: " . mysqli_connect_error());
		} else {
			echo "Connected successfully to the database! <br>";
		}

		echo "<b> <center>Database output:</center> </b> <br> <br>";

		$result = mysqli_query($conn,"SELECT * FROM customers");

		echo "<table border='1'>
		<tr>
		<th>customer ID</th>
		<th>customer name</th>
		<th>server name</th>
		<th>environment</th>
		<th>number of environments</th>
		</tr>";

		while($row = mysqli_fetch_array($result))
		{
		echo "<tr>";
		echo "<td>" . $row['customer_ID'] . "</td>";
		echo "<td>" . $row['customer_name'] . "</td>";
		echo "<td>" . $row['server_name'] . "</td>";
		echo "<td>" . $row['environment'] . "</td>";
		echo "<td>" . $row['no_environments'] . "</td>";
		echo "</tr>";
		}
		echo "</table>";

		mysqli_close($con);
		echo "Made by Justin Oudijk - s1149860 - Windesheim university of applied sciences"
		?>
	</body>
</html>