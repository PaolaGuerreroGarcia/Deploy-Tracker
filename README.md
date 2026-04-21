# Deploy-Tracker
Herramienta interna para planificar y hacer seguimiento de despliegues a producción

Para guardar los archivos en Supabase
Lo único que necesitas hacer en Supabase antes de usarlo:

Ve a tu proyecto → Storage → New bucket
Nombre: deploy-files
Actívalo como Public (para que los links de descarga funcionen sin autenticación)

En Supabase → Database → Extensions, busca pg_cron y actívala.

El cron borra los registros de la tabla y periódicamente, se debe hacer una limpieza manual del bucket desde el dashboard de Supabase → Storage → lista los archivos y filtra por fecha. 

