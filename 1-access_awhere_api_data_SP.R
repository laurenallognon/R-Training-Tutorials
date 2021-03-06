#--------------------------------------------------------------------------
# aWhere R Tutorial: Access aWhere API Data 
# Tutuorial de R de aWhere: Accesando a los datos del API de aWhere
#
# Purpose of script: 
# This code will show you how to access aWhere's ag-weather datasets from 
# the API (Application Programming Interface) for your location of interest. 
# Prior to running this script, we enourage you to find the latitude and 
# longitude of an area of interest by using Google Maps, QGIS and aWhere's 
# geospatial files found on apps.awhere.com, or by using GPS points that you 
# have previously collected. 
#
# This script provides the following datasets for your location of interest:
# 1. A csv output of the Forecast (Hourly, 6 hour, 12-hour, 
#      or daily blocks of time) 
# 2. Observed data for any time period between 2008 and present
# 3. Long-Term Normals (LTN) for chosen time period between 2008 and present
# 4. A csv output called the "aWhere Weather Dataset" which includes all 
#      observed variables and all LTN variables including the differences 
#      from normal. 
#
# You will need to be connected to the internet to run this script.
#
# Proposito del Script:
# Este codigo le mostrara como acceder a las bases agrometeorologicas de aWhere
# a partir de nuestro API (Interfaz de Programacion de Aplicaciones) para su area de interes.
# Antes de ejecutar este script, le solicitamos encontrar la latitud y la longitud de su
# sitio de interes, ya sea utilizando Google Maps, QGIS o bien, los archivos geoespaciales de
# aWhere disponibles en apps.awhere.com o, utilizando puntos GPS que usted haya obtenido previamente.
#
# Este script le provee a usted las siguientes bases de datos para su sitio de interes:
# 1. Un archivo csv con el pronostico del tiempo (Horario, a 6 horas, a 12 horas o en franjas diarias de tiempo).
# 2. Datos observados para cualquier periodo de tiempo entre el 2008 y el presente.
# 3. Valores promedio a largo plazo (LTN) de las variables meteorologicas para un periodo escogido entre el 2008 y
# el presente.
# 4. Un archivo csv llamado "aWhere Weather Dataset" que incluye todas las variables observadas y todas las
# variables LTN incluyendo las diferencias con respecto a los valores normales.
#
# Usted necesita estar conectado a internet para ejecutar este codigo.
#
# Date updated: 2020-04-14
# Fecha de actualizacion: 2020-04-14
#--------------------------------------------------------------------------


# Install and load packages -----------------------------------------------
# Instalar y cargar paquetes ----------------------------------------------

# Clear your environment and remove all previous variables
# Limpie su entorno y remueva todas las variables previas
rm(list = ls())

# Install the aWhere R packages, if you have not already
# Instale los paquetes de R de aWhere, si no lo ha hecho previamente
devtools::install_github("aWhereAPI/aWhere-R-Library")
devtools::install_github("aWhereAPI/aWhere-R-Charts")

# Load the packages needed for this script.
# If they have not been installed yet on your computer, 
# using this code to install them: install.packages("NAME OF PACKAGE")

# Cargue los paquetes necesarios para este script.
# Si estos no han sido instalados aun en su computadora,
# use este comando para instalarlo: install.packages("NOMBRE DEL PAQUETE")
library(devtools)
library(rgeos)
library(raster)
library(foreach)
library(aWhereAPI)
library(aWhereCharts)


# Load aWhere credentials -------------------------------------------------
# Cargue sus credenciales de aWhere ---------------------------------------

# You will need to load your credentials file which includes your aWhere 
# key and secret, like a username and password. This gives you a token which 
# shows that you have access to the API and all of aWhere's data. Your 
# credentials should be kept in a location where you can easily find them. 
# Copy the pathfile name and paste it below over the phrase, 
# "YOUR CREDENTIALS HERE"

# Es necesario cargar su Archivo de Credenciales que incluye su Key & Secret
# de aWhere, similar a un nombre de usuario y contrase�a. Esto le brinda una
# especie de "Token" que muestra que usted tiene acceso al API y a todos los datos de aWhere.
# Debe de mantener sus credenciales en una ubicacion que pueda hallar facilmente.
# Copie la ruta de acceso de este archivo y pegue esta sobre la frase "YOUR CREDENTIALS HERE"

aWhereAPI::load_credentials("YOUR CREDENTIALS HERE")


# Set working & output directories ----------------------------------------
# Establezca sus directorios de trabajo y de salidas ----------------------

# Next, you need to set your working directory. This is the location on your 
# computer where R will automatically save the output files created by this 
# script.

# To set your working directory, find the folder on your computer where you 
# would like the outputs of this script to be saved, copy the pathfile name 
# and paste it over the phrase, "YOUR WD HERE"

# A continuacion, usted necesita establecer su directorio de trabajo. Este es el lugar
# en su computadora en el que R va a guardar los archivos de salida de este script.

# Para establecer su directorio de trabajo, busque la carpeta en su computadora en la cual
# usted desea que las salidas de este script se guarden, copie la ruta de acceso y pegue
# esta sobre la frase "YOUR WD HERE"

working_dir <- "YOUR WD HERE" 
setwd(working_dir) # This sets your working directory to the working_dir path
                   # Esto establece su directorio de trabajo en la ruta de acceso de working_dir

# Now you will create the folder within your working directory where your 
# output csv files will be saved. This line creates a folder in your working 
# directory called outputCSVs. You can navigate to your working directory on 
# your computer and see that this folder was created.

# Ahora usted va a crear la carpeta dentro de su directorio de trabajo en la que
# sus archivos csv de salida se van a guardar. La siguiente linea crea una carpeta
# en su directorio de trabajo llamada outputCSVs.Puede navegar a su directorio de trabajo
# en su computadora para verificar que esta carpeta fue creada.

dir.create(path = "outputCSVs/", showWarnings = FALSE, recursive = TRUE) 

# Now that your parameters have been set for this script, you are ready to 
# begin requesting data from the API and investigating your area of interest.

# Una vez establecidos sus parametros para este script, usted esta listo
# para empezar a solicitar datos de la API e investigar mas a fondo para su area de interes.


# Forecast ----------------------------------------------------------------
# Pronostico --------------------------------------------------------------

# In this section, we will pull forecast data for your location of interest. 
# First, determine the location's name, latitude, and longitude. 
# You can use QGIS, Google Maps, or your own data to find this information.
# Next, create a text file with this location information. Refer to 
# the "locations.txt" text file example in the RunSet folder for formatting
# this file. It must have 3 columns called place_name, latitude, longitude. 
# An example of a row with location information would thus be:
#     place_name, latitude, longitude
#     Nairobi, -1.283, 36.816

# En esta seccion, vamos a obtener los datos del pronostico para su sitio de interes.
# Primero, determine el nombre la ubicacion, su latitud y longitud.
# Puede usar QGIS, Google Maps, o sus propios datos para encontrar esta informacion.
# Seguidamente, cree el siguiente archivo de texto con la informacion de la ubicacion.
# Refierase al archivo de texto de ejemplo "locations.txt" en la carpeta RunSet para darle
# formato a este archivo. Debe de tener 3 columnas con los nombres place_name, latitude, longitude.
# Un ejemplo de una fila con la informacion de la ubicacion seria:
#     place_name, latitude, longitude
#     Nairobi, -1.283, 36.816

# CHANGE THIS to the path of your locations text file
# CAMBIE ESTO por la ruta de acceso de su archivo de texto "locations.txt"
locations_file <- "YOUR LOCATION FILE.txt" 

# Read the location(s) text file 
# Lea su archivo de texto de ubicacion(es)
locations <- read.csv(locations_file)

for (i in(1:nrow(locations))) { 
  # Get the first latitude, longitude, and name of your location(s) of interest
  # Obtenga las primeras latitudes, longitudes y nombre de su(s) sitio(s) de interes
  lat <- locations$latitude[i]
  lon <- locations$longitude[i]
  place_name <- locations$place_name[i]
  
  # Pull the weather forecast directly from the aWhere API
  # Obtenga el pronostico del tiempo directamente desde nuestra API
  forecast <- aWhereAPI::forecasts_latlng(lat
                                           ,lon 
                                           ,day_start = as.character(Sys.Date()) 
                                           ,day_end = as.character(Sys.Date()+7)
                                           ,block_size = 6) 
  #  The default forecast parameters in the code above are: 
  #  Starting date is today, Sys.Date()
  #  Ending date is seven days from now, Sys.Date() + 7
  #  Block size refers to the number of hours each data point will consist 
  #  of. By default, this value is 6, which pulls forecast data in 6-hour blocks. 
  #  A block size of 1 would yield hourly blocks of forecast data. 
  
  # Los parametros por defecto del pronostico del codigo anterior son:
  # La fecha de inicio es hoy, Sys.Date()
  # La fecha final es siete dias a partir de ahora, Sys.Date() +7
  # Block size se refiere al numero de horas que se representara en cada punto. Este valor es de 6,
  # pues obtiene los datos del pronostico para bloques de 6 horas. Un block size de 1 brindara
  # el pronostico en bloques de una hora.
  
  # Save a .csv file of the forecast data in the outputCSVs folder that you 
  # created within your working directory
  # Guarde los datos del pronostico en un archivo .csv dentro de la carpeta outputCSVs
  # que usted creo dentro de su directorio de trabajo.
  
  write.csv(forecast, file = paste0("outputCSVs/Forecast-6hour-",place_name,".csv"), row.names=F) 
  
  # You can also click on the forecast dataframe in the "environment" tab in the 
  # top right console to see the data in RStudio!
  
  # Puede tambien hacer clic en el dataframe del pronostico en la pesta�a "Environment"
  # en la consola superior derecha para ver los datos en RStudio.
  
  
  # Observed Data -----------------------------------------------------------
  # Datos Observados --------------------------------------------------------
  
  # Here you will pull the historical data for your location of interest.
  # Aqui vamos a agregar los datos historicos para su area de interes.
  
  # Set the starting and ending dates to a time period of interest
  # Establezca sus fechas de inicio y fin para un periodo de interes
  starting_date <- "2018-01-01" # January 1, 2016
                                # 1ero de enero, 2016
  ending_date <- as.character(Sys.Date() - 2) # two days ago
                                              # hace dos dias
  # Pull observed weather data from the aWhere API 
  # Obtenga los datos meteorologicos observados a partir del API de aWhere
  observed <- aWhereAPI::daily_observed_latlng(latitude = lat,
                                               longitude = lon,
                                               day_start = starting_date,
                                               day_end = ending_date)
  
  write.csv(observed, file = paste0("outputCSVs/observedData-",place_name,".csv"), row.names=F) 
  
  # The parameters for this function can have many formats.
  # You can change the starting/ending dates for a timeframe of interest. 
  #   The starting date can be as early as 2008. 
  #   You can use the "YYYY-MM-DD" format for a specific date.
  #   You can also use Sys.Date() to make your end date today, 
  #   or similarly, use Sys.Date() - 1 to make your end date yesterday. 
  #   NOTE that observed data can ONLY be in the past. You will get an error 
  #   if a future date is selected! 
  
  # Los parametros para esta funciion pueden tener muchos formatos.
  # Usted puede cambiar las fechas de inicio/fin para un periodo de interes.
  # Puede utilizar el formato "AAAA-MM-DD" para una fecha especifica.
  # Tambien pude utilizar Sys.Date() para que su fecha final sea hoy,
  # o de forma similar, puede usar Sys.Date() - 1 para que su fecha final sea ayer.
  # NOTE que los datos observados SOLO pueden pertenecer al pasado. Si selecciona 
  # una fecha futura el sistema le indicara un error.
  
  # Click the "observed" dataframe in the "environment" tab on the top right 
  # console to see the data!
  
  # Haga clic en el dataframe "observed" en la pesta�a "environment" en la consola 
  # superior derecha para ver los datos.
  
  
  # Agronomic data ----------------------------------------------------------
  # Datos Agronomicos -------------------------------------------------------
  
  # Here you will pull agronomic data for your location and time of interest. 
  # If you do not change the "starting_date" and "ending_date" variables,
  # then the time period will remain the same from the observed data pulled above. 
  
  # Aqui usted va a obtener los datos agronomicos para su lugar y periodo de interes.
  # Si no cambia las variables de "starting_date" y "ending_date", entonces
  # el periodo tiempo de los datos va a ser el mismo de los Datos Observados que se obtuvieron previamente.
  
  # Pull agronomic weather data from the aWhere API
  # Obtener los datos agronomicos a partir del API de aWhere
  ag <- aWhereAPI::agronomic_values_latlng(lat
                                            ,lon 
                                            ,day_start = starting_date 
                                            ,day_end = ending_date)
  
  # Click the "ag" dataframe in the "environment" tab on the top right 
  # console to see the data!
  
  # Haga clice en el dataframe "ag" de la pesta�a "environment" en la consola superior derecha
  # para ver los datos.
  
  write.csv(ag, file = paste0("outputCSVs/agronomicsData-",place_name,".csv"), row.names=F) 
  
  # Long Term Normals -------------------------------------------------------
  # Valores promedio a largo plazo (LTN) ------------------------------------
  
  # Here you will pull the long-term normals (LTN) for your location and time 
  # period of interest. 
  
  # Aqui usted podra obtener los valores promedio a largo plazo (LTN) de las variables meteorologicas
  # para su sitio y periodo de interes.
  
  # LTN values will be calculated across this range of years 
  # Las variables LTN se calculan a partir de un rango de a�os.
  year_start <- 2011
  year_end <- 2018
  
  # Specify the starting and ending month-day of interest, 
  # such as the growing season in your region 
  
  # Por favor especifique su mes-dia de inicio y de fin,
  # asi como tambien su "temporada de crecimiento" de cultivos
  monthday_start <- "01-01" # January 1
                            # Enero 1
  
  monthday_end <- "06-16"   # June 16
                            # Junio 16
  
  # Pull LTN weather data from the aWhere API 
  # Obtenga los datos meteorologicos LTN a partir del API de aWhere
  ltn <- weather_norms_latlng(lat, lon,
                               monthday_start = monthday_start,
                               monthday_end = monthday_end,
                               year_start = year_start,
                               year_end = year_end,
                               # you can choose to exclude years from the LTN
                               # puede tambien excluir ciertos a�os de las variables LTN
                               exclude_years = c("2011", "2016")) 
  
  # Click the "ltn" dataframe in the "environment" tab on the top right 
  # console to see the data!  
  
  # Haga clic en el dataframe "ltn" en la pesta�a "environment" en la consola superior derecha
  # para ver los datos.
  
  write.csv(ltn, file = paste0("outputCSVs/ltnData-",place_name,".csv"), row.names=F) 
  
  # Full aWhere Ag-Weather Dataset ------------------------------------------
  # Base de datos aWhere Ag-Weather Dataset completa ------------------------
  
  # This section combines all of the above datasets into one cohesive .csv for 
  # analysis. You can change the location and time period as needed in 
  # the lines of code below. 
  
  # Esta seccion combina todas las bases de datos anteriores de una forma cohesiva
  # en un archivo .csv para su posterior analisis. Puede cambiar la ubicacion y periodo de interes,
  # segun sea el caso en las lineas siguientes del codigo.
  
  starting_date <- "2018-01-01"
  ending_date <- "2019-06-16"
  year_start <- 2008
  year_end <- 2018
  
  # This function generates a clean dataset with observed AND forecast 
  # agronomics AND Long Term Normals!
  
  # La siguiente funcion crea un conjunto de datos depurados con los datos observados, 
  # los datos agronomicos y los valores promedio a largo plazo.
  weather_df <- generateaWhereDataset(lat = lat, 
                                      lon = lon, 
                                      day_start = starting_date, 
                                      day_end = ending_date, 
                                      year_start = year_start, 
                                      year_end = year_end)
  
  # Save .csv file of the dataset in the outputCSVs folder created within 
  # your working directory
  
  # Guarde el archivo .csv del conjunto de datos en la carpeta outputCSVs que fue creada
  # dentro de su directorio de trabajo.
  write.csv(weather_df, 
            file = paste0("outputCSVs/aWhereWeatherDataset-",place_name,".csv"), 
            row.names=F) 
}

