def upsert_product(name:, normalized_name:, category:, description:, aliases: [])
	product = Product.find_or_initialize_by(normalized_name: normalized_name)
	product.name = name
	product.category = category
	product.description = description
	product.save!

	aliases.each do |alias_name|
		product_alias = ProductAlias.find_or_initialize_by(name: alias_name)
		product_alias.product = product
		product_alias.save!
	end

	product
end

def upsert_price(product:, brand:, quality:, value:, unit:, unit_quantity:, date: Date.current)
	price = Price.find_or_initialize_by(
		product: product,
		brand: brand,
		quality: quality,
		unit: unit,
		unit_quantity: unit_quantity,
		date: date
	)
	price.value = value
	price.save!
end

qualities = {
	economica: Quality.find_or_create_by!(level: 'economica') { |q| q.description = 'Linea economica'; q.quality_factor = 0.9 },
	estandar: Quality.find_or_create_by!(level: 'estandar') { |q| q.description = 'Linea estandar'; q.quality_factor = 1.0 },
	premium: Quality.find_or_create_by!(level: 'premium') { |q| q.description = 'Linea premium'; q.quality_factor = 1.2 }
}

brands = {
	alpha: Brand.find_or_create_by!(name: 'Alpha Escolar') { |b| b.country = 'Peru' },
	omega: Brand.find_or_create_by!(name: 'Omega Kids') { |b| b.country = 'Peru' },
	andina: Brand.find_or_create_by!(name: 'Andina Studio') { |b| b.country = 'Peru' }
}

products = {}

products[:cuaderno_100_grande] = upsert_product(
	name: 'Cuaderno rayado 100 hojas grande',
	normalized_name: 'cuaderno-rayado-100-hojas-grande',
	category: 'cuadernos',
	description: 'Cuaderno escolar rayado de 100 hojas tamano grande',
	aliases: ['Cuadernos de 100 hojas tamano grande', 'Cuaderno 100 hojas grande']
)

products[:cuaderno_100_pequeno] = upsert_product(
	name: 'Cuaderno cuadriculado 100 hojas pequeno',
	normalized_name: 'cuaderno-cuadriculado-100-hojas-pequeno',
	category: 'cuadernos',
	description: 'Cuaderno escolar cuadriculado de 100 hojas tamano pequeno',
	aliases: ['Cuaderno 100 hojas pequeno', 'Cuaderno cuadriculado pequeno']
)

products[:plumon_12] = upsert_product(
	name: 'Plumones indelebles x 12',
	normalized_name: 'plumones-indelebles-x-12',
	category: 'marcadores',
	description: 'Set de plumones indelebles por 12 unidades',
	aliases: ['Plumones x 12', 'Plumones indelebles por 12']
)

products[:lapiz_hb] = upsert_product(
	name: 'Lapiz grafito HB',
	normalized_name: 'lapiz-grafito-hb',
	category: 'escritura',
	description: 'Lapiz grafito HB para uso escolar',
	aliases: ['Lapiz HB', 'Lapiz grafito escolar']
)

products[:colores_12] = upsert_product(
	name: 'Colores de madera x 12',
	normalized_name: 'colores-madera-x-12',
	category: 'arte',
	description: 'Caja de colores de madera por 12',
	aliases: ['Colores x 12', 'Colores de madera por 12']
)

products[:block_cartulina_colores_36] = upsert_product(
	name: 'Block de cartulina de colores 36 hojas',
	normalized_name: 'block-cartulina-colores-36-hojas',
	category: 'papeleria',
	description: 'Block de cartulina de colores de 36 hojas tamano grande',
	aliases: ['block de cartulina de colores 36 hojas 24.5 x 34.5 cm', 'block de cartulina de colores grande']
)

products[:block_cartulina_blanca_a4] = upsert_product(
	name: 'Block de cartulina blanca A4',
	normalized_name: 'block-cartulina-blanca-a4',
	category: 'papeleria',
	description: 'Block de cartulina blanca tamano A4',
	aliases: ['block de cartulina blanca a4', 'cartulina blanca a4']
)

products[:papel_bond_oficio] = upsert_product(
	name: 'Papel bond oficio blanco',
	normalized_name: 'papel-bond-oficio-blanco',
	category: 'papeleria',
	description: 'Pliegos de papel bond oficio color blanco',
	aliases: ['pliegos de papel bond oficio blanco', 'papel bond 8 oficio blanco']
)

products[:block_hojas_colores] = upsert_product(
	name: 'Block de hojas de colores arco iris',
	normalized_name: 'block-hojas-colores-arco-iris',
	category: 'papeleria',
	description: 'Block de hojas de colores para manualidades',
	aliases: ['block de hojas de colores', 'block de hojas de colores arco iris']
)

products[:block_hojas_diseno] = upsert_product(
	name: 'Block de hojas con diseno',
	normalized_name: 'block-hojas-con-diseno',
	category: 'papeleria',
	description: 'Block de hojas decoradas con diseno',
	aliases: ['block de hojas con diseno', 'block de hojas con disefio']
)

products[:folder_oficio_plastificado] = upsert_product(
	name: 'Folder oficio plastificado',
	normalized_name: 'folder-oficio-plastificado',
	category: 'organizacion',
	description: 'Folder tamano oficio plastificado',
	aliases: ['folder tamano oficio plastificado', 'fdelder tamafio oficio plastificado']
)

products[:plastilina_jumbo_12] = upsert_product(
	name: 'Plastilina jumbo x 12',
	normalized_name: 'plastilina-jumbo-x-12',
	category: 'arte',
	description: 'Caja de plastilina jumbo por 12 unidades',
	aliases: ['caja por 12 unid. de plastilina jumbo', 'plastilina jumbo 200g x 12']
)

products[:lapices_colores_24] = upsert_product(
	name: 'Lapices de colores triangulares x 24',
	normalized_name: 'lapices-colores-triangulares-x-24',
	category: 'arte',
	description: 'Estuche de lapices de colores triangulares largos por 24',
	aliases: ['estuche de lapices de colores triangulares largos x 24', 'estuche de ldpices de colores triangulares largos x 24 unid.']
)

products[:cartulina_negra] = upsert_product(
	name: 'Cartulina negra',
	normalized_name: 'cartulina-negra',
	category: 'papeleria',
	description: 'Pliego de cartulina color negro',
	aliases: ['pliego de cartulina negra']
)

products[:cartulina_corrugada_metalica] = upsert_product(
	name: 'Cartulina corrugada metalica',
	normalized_name: 'cartulina-corrugada-metalica',
	category: 'papeleria',
	description: 'Pliego de cartulina corrugada metalica de colores',
	aliases: ['pliego de cartulina corrugada metalica', 'cartulina corrugada metdlica']
)

products[:papel_crepe_colores] = upsert_product(
	name: 'Papel crepe de colores',
	normalized_name: 'papel-crepe-colores',
	category: 'papeleria',
	description: 'Pliegos de papel crepe de colores surtidos',
	aliases: ['pliegos de papel crepe colores', 'papel crepe colores']
)

products[:tempera_250ml] = upsert_product(
	name: 'Tempera 250 ml',
	normalized_name: 'tempera-250-ml',
	category: 'pintura',
	description: 'Frasco de tempera de 250 ml',
	aliases: ['frascos de tempera de 250ml', 'tempera 250ml']
)

products[:tijera_punta_roma] = upsert_product(
	name: 'Tijera punta roma escolar',
	normalized_name: 'tijera-punta-roma-escolar',
	category: 'escritura',
	description: 'Tijera escolar de punta roma',
	aliases: ['tijera punta roma', 'tijera punta roma con nombre']
)

products[:lapiz_2b] = upsert_product(
	name: 'Lapiz triangular 2B',
	normalized_name: 'lapiz-triangular-2b',
	category: 'escritura',
	description: 'Lapiz triangular 2B sin borrador',
	aliases: ['lapices triangulares 2b', 'ldpices triangulares 2b sin borrador grip']
)

products[:plumones_delgados_12] = upsert_product(
	name: 'Plumones delgados x 12',
	normalized_name: 'plumones-delgados-x-12',
	category: 'marcadores',
	description: 'Estuche de plumones delgados de colores por 12',
	aliases: ['estuche de plumones delgados de colores x 12']
)

products[:plumones_gruesos_12] = upsert_product(
	name: 'Plumones gruesos x 12',
	normalized_name: 'plumones-gruesos-x-12',
	category: 'marcadores',
	description: 'Estuche de plumones gruesos de colores por 12',
	aliases: ['estuche de plumones gruesos de colores x 12']
)

products[:silicona_liquida_250] = upsert_product(
	name: 'Silicona liquida 250 ml',
	normalized_name: 'silicona-liquida-250-ml',
	category: 'manualidades',
	description: 'Silicona liquida escolar de 250 ml',
	aliases: ['siliconas liquidas de 250ml', 'silicona liquida 250ml']
)

products[:micas_a4_10] = upsert_product(
	name: 'Micas A4 x 10',
	normalized_name: 'micas-a4-x-10',
	category: 'organizacion',
	description: 'Bolsa por 10 unidades de micas tamano A4',
	aliases: ['bolsa por 10 unidades de micas tamano a4', 'micas tamatio a-4']
)

products[:archivador_grande] = upsert_product(
	name: 'Archivador grande',
	normalized_name: 'archivador-grande',
	category: 'organizacion',
	description: 'Archivador grande forrado para documentos escolares',
	aliases: ['archivador grande forrado', 'archivador grande color violeta']
)

products[:crayolas_delgadas] = upsert_product(
	name: 'Crayolas delgadas',
	normalized_name: 'crayolas-delgadas',
	category: 'arte',
	description: 'Caja de crayolas delgadas de colores',
	aliases: ['caja de crayolas delgadas', 'crayolas delgadas']
)

products[:activador_slime_250] = upsert_product(
	name: 'Activador magico de slime 250 ml',
	normalized_name: 'activador-magico-slime-250-ml',
	category: 'manualidades',
	description: 'Activador magico para slime crunchy de 250 ml',
	aliases: ['activador magico de slime crunchy de 250ml', 'activador mdgico de slime']
)

products[:goma_transparente_120] = upsert_product(
	name: 'Goma transparente para slime 120 ml',
	normalized_name: 'goma-transparente-slime-120-ml',
	category: 'manualidades',
	description: 'Goma transparente para slime de 120 ml',
	aliases: ['goma trasparente para slime de 120ml', 'goma transparente slime']
)

products[:goma_metalica_120] = upsert_product(
	name: 'Goma metalica 120 ml',
	normalized_name: 'goma-metalica-120-ml',
	category: 'manualidades',
	description: 'Goma metalica para manualidades de 120 ml',
	aliases: ['goma metalica de 120 ml', 'goma metdlica de 120 ml']
)

products[:goma_confeti_120] = upsert_product(
	name: 'Goma confeti 120 ml',
	normalized_name: 'goma-confeti-120-ml',
	category: 'manualidades',
	description: 'Goma con confeti para manualidades de 120 ml',
	aliases: ['goma confeti de 120 ml']
)

products[:cinta_embalaje_gruesa] = upsert_product(
	name: 'Cinta de embalaje gruesa',
	normalized_name: 'cinta-embalaje-gruesa',
	category: 'manualidades',
	description: 'Cinta de embalaje gruesa transparente',
	aliases: ['cintas de embalaje gruesa', 'o2 cintas de embalaje gruesa']
)

products[:masking_tape_set] = upsert_product(
	name: 'Masking tape gruesa mediana delgada',
	normalized_name: 'masking-tape-gruesa-mediana-delgada',
	category: 'manualidades',
	description: 'Set de cintas masking tape de tres grosores',
	aliases: ['cintas maskin tape gruesa mediana y delgada', 'maskin tape']
)

products[:lana_gruesa] = upsert_product(
	name: 'Lana gruesa',
	normalized_name: 'lana-gruesa',
	category: 'manualidades',
	description: 'Madeja de lana gruesa de colores',
	aliases: ['madejas de lana gruesa', 'lana gruesa de distintos colores']
)

products[:pano_lenci] = upsert_product(
	name: 'Pano lenci',
	normalized_name: 'pano-lenci',
	category: 'manualidades',
	description: 'Pano lenci de colores para manualidades',
	aliases: ['pafio lenci color rosado y naranja', 'pano lenci']
)

products[:yute_verde] = upsert_product(
	name: 'Yute color verde por metro',
	normalized_name: 'yute-color-verde-metro',
	category: 'manualidades',
	description: 'Metro de yute color verde',
	aliases: ['metro de yute color verde']
)

products[:cola_de_rata] = upsert_product(
	name: 'Cola de rata para manualidades',
	normalized_name: 'cola-de-rata-manualidades',
	category: 'manualidades',
	description: 'Bola de cola de rata para tejido y decoracion',
	aliases: ['bola de cola de rata']
)

products[:tenedores_descartables] = upsert_product(
	name: 'Tenedores descartables',
	normalized_name: 'tenedores-descartables',
	category: 'sensorial',
	description: 'Paquete de tenedores descartables',
	aliases: ['paquete de tenedores descartables']
)

products[:algodon] = upsert_product(
	name: 'Algodon',
	normalized_name: 'algodon',
	category: 'sensorial',
	description: 'Paquete de algodon para actividades',
	aliases: ['paquete de algodon']
)

products[:hisopos] = upsert_product(
	name: 'Hisopos',
	normalized_name: 'hisopos',
	category: 'sensorial',
	description: 'Paquete de hisopos',
	aliases: ['paquete de hisopos']
)

products[:ojos_movibles_docena] = upsert_product(
	name: 'Ojos movibles por docena',
	normalized_name: 'ojos-movibles-docena',
	category: 'manualidades',
	description: 'Docena de ojos movibles para manualidades',
	aliases: ['docena de ojos movibles']
)

products[:lentejuelas_docena] = upsert_product(
	name: 'Lentejuelas por docena',
	normalized_name: 'lentejuelas-docena',
	category: 'manualidades',
	description: 'Docena de lentejuelas con formas',
	aliases: ['docena de lentejuelas con diseno o formas', 'docena de lentejuelas con disefio o formas']
)

products[:botones_docena] = upsert_product(
	name: 'Botones por docena',
	normalized_name: 'botones-docena',
	category: 'manualidades',
	description: 'Docena de botones para manualidades',
	aliases: ['docena de botones', '12 botones reciclados']
)

products[:tiza_caja] = upsert_product(
	name: 'Caja de tiza',
	normalized_name: 'caja-de-tiza',
	category: 'escritura',
	description: 'Caja de tizas escolares',
	aliases: ['caja de tiza']
)

products[:oleo_pastel] = upsert_product(
	name: 'Oleo pastel',
	normalized_name: 'oleo-pastel',
	category: 'arte',
	description: 'Caja de oleo pastel para dibujo',
	aliases: ['caja de oleo pastel', 'caja de dleo pastel']
)

products[:palitos_helado_gruesos] = upsert_product(
	name: 'Palitos de helado gruesos',
	normalized_name: 'palitos-helado-gruesos',
	category: 'manualidades',
	description: 'Paquete de palitos de helado gruesos',
	aliases: ['paquete de palitos de helado gruesos', 'un paquete de palitos de helado gruesos']
)

products[:chenille_metalico] = upsert_product(
	name: 'Chenille metalico',
	normalized_name: 'chenille-metalico',
	category: 'manualidades',
	description: 'Paquete de chenille metalico para manualidades',
	aliases: ['paquete de chenille metalico', 'paquete de chenille metdlico']
)

products[:cuento_grande] = upsert_product(
	name: 'Cuento grande de hojas gruesas',
	normalized_name: 'cuento-grande-hojas-gruesas',
	category: 'lectura',
	description: 'Cuento ilustrado grande de hojas gruesas',
	aliases: ['cuento con imagenes grande de hojas gruesas', 'cuento con imagenes grande de hojas gruesas donacion']
)

products[:semola_250] = upsert_product(
	name: 'Semola 250 gr',
	normalized_name: 'semola-250-gr',
	category: 'sensorial',
	description: 'Paquete de semola de 250 gramos',
	aliases: ['paquete de semola de 250gr', 'paquete de sdmola de 250gr']
)

products[:harina_250] = upsert_product(
	name: 'Harina 250 gr',
	normalized_name: 'harina-250-gr',
	category: 'sensorial',
	description: 'Harina de trigo de 250 gramos',
	aliases: ['250 gr de harina']
)

products[:maicena_250] = upsert_product(
	name: 'Maicena 250 gr',
	normalized_name: 'maicena-250-gr',
	category: 'sensorial',
	description: 'Maicena de 250 gramos para actividades sensoriales',
	aliases: ['250 gr de maicena']
)

products[:arroz_250] = upsert_product(
	name: 'Arroz 250 gr',
	normalized_name: 'arroz-250-gr',
	category: 'sensorial',
	description: 'Arroz de 250 gramos para actividades sensoriales',
	aliases: ['250 gr de arroz']
)

products[:fideo_canuto] = upsert_product(
	name: 'Fideo canuto pequeno',
	normalized_name: 'fideo-canuto-pequeno',
	category: 'sensorial',
	description: 'Paquete de fideo canuto pequeno para actividades',
	aliases: ['paquetes de fideo canuto pequeno', 'fideo canuto pequefio']
)

products[:mini_botellas_recicladas] = upsert_product(
	name: 'Mini botellas recicladas',
	normalized_name: 'mini-botellas-recicladas',
	category: 'sensorial',
	description: 'Mini botellas recicladas de gaseosa lavadas',
	aliases: ['mini botellas recicladas de gaseosa', '04 mini botellas recicladas de gaseosa lavadas']
)

products[:panuelo] = upsert_product(
	name: 'Panuelo o panoleta',
	normalized_name: 'panuelo-o-panoleta',
	category: 'personal',
	description: 'Panuelo o panoleta personal',
	aliases: ['pafuelo o pafoleta', 'pafiuelo o pafioleta']
)

products[:toalla_manos] = upsert_product(
	name: 'Toalla para manos',
	normalized_name: 'toalla-para-manos',
	category: 'personal',
	description: 'Toalla para manos con nombre',
	aliases: ['toalla para manos con nombre bordado y oreja']
)

price_matrix = {
	cuaderno_100_grande: [3.9, 4.8, 6.2],
	cuaderno_100_pequeno: [3.5, 4.2, 5.6],
	plumon_12: [11.0, 13.5, 18.0],
	lapiz_hb: [0.7, 0.95, 1.3],
	colores_12: [7.2, 9.5, 13.0],
	block_cartulina_colores_36: [4.6, 5.9, 7.5],
	block_cartulina_blanca_a4: [3.8, 4.9, 6.1],
	papel_bond_oficio: [0.4, 0.6, 0.85],
	block_hojas_colores: [4.0, 5.2, 6.4],
	block_hojas_diseno: [4.4, 5.8, 7.0],
	folder_oficio_plastificado: [2.2, 3.0, 4.0],
	plastilina_jumbo_12: [8.8, 10.9, 14.4],
	lapices_colores_24: [9.5, 12.0, 16.8],
	cartulina_negra: [0.9, 1.2, 1.8],
	cartulina_corrugada_metalica: [2.0, 2.8, 3.9],
	papel_crepe_colores: [1.2, 1.8, 2.5],
	tempera_250ml: [5.5, 7.4, 9.8],
	tijera_punta_roma: [3.8, 5.0, 6.7],
	lapiz_2b: [0.8, 1.1, 1.5],
	plumones_delgados_12: [10.5, 13.2, 17.1],
	plumones_gruesos_12: [11.4, 14.0, 18.3],
	silicona_liquida_250: [4.6, 6.0, 7.8],
	micas_a4_10: [5.8, 7.2, 9.5],
	archivador_grande: [11.8, 14.5, 18.6],
	crayolas_delgadas: [4.2, 5.8, 7.6],
	activador_slime_250: [6.4, 8.1, 10.9],
	goma_transparente_120: [3.2, 4.4, 5.9],
	goma_metalica_120: [3.8, 4.9, 6.2],
	goma_confeti_120: [3.9, 5.0, 6.3],
	cinta_embalaje_gruesa: [4.1, 5.3, 6.8],
	masking_tape_set: [6.2, 7.8, 10.0],
	lana_gruesa: [4.0, 5.3, 7.1],
	pano_lenci: [2.6, 3.7, 5.1],
	yute_verde: [2.5, 3.4, 4.7],
	cola_de_rata: [3.0, 4.2, 5.8],
	tenedores_descartables: [2.2, 3.0, 4.0],
	algodon: [2.0, 2.8, 3.7],
	hisopos: [1.8, 2.5, 3.4],
	ojos_movibles_docena: [2.7, 3.8, 5.0],
	lentejuelas_docena: [2.6, 3.6, 4.9],
	botones_docena: [2.4, 3.4, 4.7],
	tiza_caja: [2.8, 3.9, 5.3],
	oleo_pastel: [5.1, 6.8, 9.2],
	palitos_helado_gruesos: [2.9, 4.0, 5.4],
	chenille_metalico: [3.6, 4.8, 6.5],
	cuento_grande: [14.0, 18.5, 24.0],
	semola_250: [1.9, 2.6, 3.5],
	harina_250: [1.4, 1.9, 2.6],
	maicena_250: [2.3, 3.1, 4.2],
	arroz_250: [1.5, 2.0, 2.8],
	fideo_canuto: [1.7, 2.3, 3.1],
	mini_botellas_recicladas: [2.0, 2.8, 3.9],
	panuelo: [2.2, 3.0, 4.1],
	toalla_manos: [6.0, 7.9, 10.5]
}

price_matrix.each do |key, values|
	product = products[key]

	upsert_price(product: product, brand: brands[:alpha], quality: qualities[:economica], value: values[0], unit: 'unidad', unit_quantity: 1)
	upsert_price(product: product, brand: brands[:omega], quality: qualities[:estandar], value: values[1], unit: 'unidad', unit_quantity: 1)
	upsert_price(product: product, brand: brands[:andina], quality: qualities[:premium], value: values[2], unit: 'unidad', unit_quantity: 1)
end

puts "Seed completado: #{Product.count} productos, #{ProductAlias.count} aliases, #{Price.count} precios"
