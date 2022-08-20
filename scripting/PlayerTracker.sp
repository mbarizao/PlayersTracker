#include <geoip>
#include <sdktools>
#include <sourcemod>

// Define tag for print server console informations
#define TAG "[PLAYER-TRACKER]"

// Database querys
#define SQL_QUERY_CREATE_TABLE "CREATE TABLE IF NOT EXISTS `test_clients` (`id` INT(11) NOT NULL AUTO_INCREMENT,`steamId` VARCHAR(45) NOT NULL, `playerName` VARCHAR(128) NULL, `ipAddress` VARCHAR(45) NULL,`loginAt` DATETIME NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (`id`)) ENGINE = InnoDB DEFAULT CHARACTER SET = latin1 COLLATE = latin1_bin"
#define SQL_QUERY_ADD_PLAYER   "INSERT INTO `test_clients` (`steamId`, `playerName`, `ipAddress`) VALUES ('%s', '%s', '%s');"

Database MySQLdb;

public Plugin myinfo =
{
	name        = "PlayerTracker",
	description = "Tracks players connections info.",
	author      = "MarllonBrZ",
	version     = "1.0",
	url         = ""
};

public void OnPluginStart()
{
	char error[255];
	MySQLdb = SQL_DefConnect(error, sizeof(error));

	if (MySQLdb == null)
	{
		PrintToServer("%s Não foi possível conectar ao MYSQL: %s", TAG, error);
	}

	// Create a table when start plugin
	CreateTable();
}

// Add user to table
public void OnClientPostAdminCheck(int client)
{
	if (IsClientInGame(client) && !IsFakeClient(client))
	{
		char buffer[255];
		char clientId[45];
		char PlayerIP[32];
		char PlayerName[128];

		// Get SteamID
		GetClientAuthId(client, AuthId_Steam2, clientId, sizeof(clientId));

		// Get Player Name
		GetClientName(client, PlayerName, sizeof(PlayerName));
		ReplaceString(PlayerName, sizeof(PlayerName), "\"", "");
		ReplaceString(PlayerName, sizeof(PlayerName), "'", "");
		ReplaceString(PlayerName, sizeof(PlayerName), ";", "");
		ReplaceString(PlayerName, sizeof(PlayerName), "�", "");
		ReplaceString(PlayerName, sizeof(PlayerName), "`", "");

		// Player IP
		GetClientIP(client, PlayerIP, sizeof(PlayerIP));

		// Query
		Format(buffer, sizeof(buffer), SQL_QUERY_ADD_PLAYER, clientId, PlayerName, PlayerIP);

		if (!SQL_FastQuery(MySQLdb, buffer))
		{
			SQL_GetError(MySQLdb, buffer, sizeof(buffer));
			PrintToServer("-----------------------------------------------------------------------------");
			PrintToServer("%s Erro ao adicionar usuario na tabela: %s", TAG, buffer);
			PrintToServer("-----------------------------------------------------------------------------");
		}

		PrintToServer("-----------------------------------------------------------------------------");
		PrintToServer("%s Usuario %s adicionado a tabela. - [%s]", TAG, PlayerName, PlayerIP);
		PrintToServer("-----------------------------------------------------------------------------");
	}
}

// Create table if not exist
public void CreateTable()
{
	char buffer[255];

	if (SQL_FastQuery(MySQLdb, SQL_QUERY_CREATE_TABLE))
	{
		PrintToServer("-----------------------------------------------------------------------------");
		PrintToServer("%s Plugin iniciado com sucesso!", TAG);
		PrintToServer("-----------------------------------------------------------------------------");
	}
	else
	{
		char error[255];
		SQL_GetError(MySQLdb, error, sizeof(error));

		PrintToServer("-----------------------------------------------------------------------------");
		PrintToServer("%s Erro ao criar tabela %s.", TAG, error);
		PrintToServer("-----------------------------------------------------------------------------");
	}
}
