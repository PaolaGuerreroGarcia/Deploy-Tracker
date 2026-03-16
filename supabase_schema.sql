-- ============================================================
--  DEPLOY TRACKER — Schema Supabase
--  Ejecuta esto en: Supabase → SQL Editor → New query
-- ============================================================

-- 1. USUARIOS (solo nombre, sin autenticación)
create table if not exists usuarios (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  rol text not null check (rol in ('desarrollador','soporte')),
  created_at timestamptz default now()
);

-- 2. DESPLIEGUES
create table if not exists despliegues (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  fecha date not null,
  ambiente text not null,
  proyecto text not null,
  desarrollador_id uuid references usuarios(id),
  soporte_id uuid references usuarios(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 3. TAREAS
create table if not exists tareas (
  id uuid primary key default gen_random_uuid(),
  despliegue_id uuid not null references despliegues(id) on delete cascade,
  tipo text not null,
  ambiente text,
  descripcion text not null,
  link text,
  query_sql text,
  orden integer default 0,
  completada boolean default false,
  completada_por uuid references usuarios(id),
  completada_at timestamptz,
  eliminada boolean default false,
  eliminada_por uuid references usuarios(id),
  eliminada_at timestamptz,
  created_at timestamptz default now()
);

-- 4. HISTORIAL DE CAMBIOS (auditoría)
create table if not exists historial (
  id uuid primary key default gen_random_uuid(),
  entidad text not null,          -- 'despliegue' | 'tarea'
  entidad_id uuid not null,
  accion text not null,           -- 'crear' | 'editar' | 'completar' | 'descompletar' | 'eliminar'
  usuario_id uuid references usuarios(id),
  detalle jsonb,                  -- snapshot del cambio
  created_at timestamptz default now()
);

-- ============================================================
--  RLS: habilitar acceso público (ajusta según necesites)
-- ============================================================
alter table usuarios     enable row level security;
alter table despliegues  enable row level security;
alter table tareas       enable row level security;
alter table historial    enable row level security;

create policy "acceso publico usuarios"    on usuarios    for all using (true) with check (true);
create policy "acceso publico despliegues" on despliegues for all using (true) with check (true);
create policy "acceso publico tareas"      on tareas      for all using (true) with check (true);
create policy "acceso publico historial"   on historial   for all using (true) with check (true);

-- ============================================================
--  DEPLOY TRACKER — Tablas adicionales
--  Ejecuta esto en: Supabase → SQL Editor → New query
-- ============================================================

-- 1. INTEGRANTES DEL EQUIPO
create table if not exists integrantes (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  rol text not null check (rol in ('desarrollador','soporte')),
  activo boolean default true,
  orden integer default 0,
  created_at timestamptz default now()
);

-- 2. TIPOS DE TAREA
create table if not exists tipos_tarea (
  id uuid primary key default gen_random_uuid(),
  clave text not null unique,   -- 'elastic', 'lambda', etc. (usado internamente)
  etiqueta text not null,       -- 'Elastic Beanstalk' (mostrado en pantalla)
  color_bg text default '#1e2535',
  color_texto text default '#94a3b8',
  activo boolean default true,
  orden integer default 0,
  created_at timestamptz default now()
);

-- ── RLS ──
alter table integrantes  enable row level security;
alter table tipos_tarea  enable row level security;
create policy "publico integrantes" on integrantes for all using (true) with check (true);
create policy "publico tipos_tarea" on tipos_tarea for all using (true) with check (true);

-- ============================================================
--  DATOS INICIALES — Integrantes
-- ============================================================
insert into integrantes (nombre, rol, orden) values
  ('Paola Guerrero',    'desarrollador', 1),
  ('Christian Garavito','desarrollador', 2),
  ('Deyby Ariza',       'desarrollador', 3),
  ('Miguel Gonzalez',   'desarrollador', 4),
  ('Héctor Melgarejo',  'desarrollador', 5),
  ('Estefany Monsalve', 'desarrollador', 6),
  ('Jeisson Imbaña',    'desarrollador', 7),
  ('Jhoger Olmos',      'desarrollador', 8),
  ('Alisson Garay',     'desarrollador', 9),
  ('Weissman Poveda',   'soporte', 1),
  ('Nicolas Clavijo',   'soporte', 2);

-- ============================================================
--  DATOS INICIALES — Tipos de tarea
-- ============================================================
insert into tipos_tarea (clave, etiqueta, color_bg, color_texto, orden) values
  ('release',        'Aprobar release',   '#1e3a5f', '#7dd3fc', 1),
  ('elastic',        'Elastic Beanstalk', '#2d1e5f', '#c4b5fd', 2),
  ('s3',             'S3',                '#3b2e10', '#fbbf24', 3),
  ('lambda',         'Lambda',            '#0f3327', '#34d399', 4),
  ('cloudformation', 'CloudFormation',    '#1a2e1a', '#86efac', 5),
  ('db',             'Base de datos',     '#1e1040', '#a78bfa', 6),
  ('cloudfront',     'CloudFront',        '#3b1e10', '#fb923c', 7),
  ('manual',         'Acción manual',     '#1e2535', '#94a3b8', 8);

alter table usuarios
  add column if not exists ultimo_ingreso timestamptz;

alter database postgres set timezone to 'America/Bogota';

alter table despliegues add column if not exists hu_links text;