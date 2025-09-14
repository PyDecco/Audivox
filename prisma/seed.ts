import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  console.log('🌱 Seeding database...')

  // Create sample file
  const sampleFile = await prisma.file.create({
    data: {
      originalName: 'sample.pdf',
      mimeType: 'application/pdf',
      size: BigInt(1024000),
      path: '/uploads/sample.pdf',
      status: 'PROCESSED',
      metadata: {
        pages: 10,
        wordCount: 2500,
        charCount: 15000,
        language: 'pt_BR',
        title: 'Documento de Exemplo',
        author: 'Sistema'
      }
    }
  })

  console.log('✅ Sample file created:', sampleFile.id)

  // Create sample reading
  const sampleReading = await prisma.reading.create({
    data: {
      fileId: sampleFile.id,
      locale: 'PT_BR',
      startType: 'PAGE',
      startValue: 1,
      speed: 1.0,
      format: 'WAV',
      status: 'DONE',
      progress: 1.0,
      currentPage: 10,
      totalPages: 10,
      audioPath: '/audio/sample.wav',
      audioSize: BigInt(2048000),
      duration: 120,
      completedAt: new Date()
    }
  })

  console.log('✅ Sample reading created:', sampleReading.id)

  // Create sample audio chunks
  for (let i = 1; i <= 10; i++) {
    await prisma.audioChunk.create({
      data: {
        readingId: sampleReading.id,
        pageNumber: i,
        duration: 12,
        size: BigInt(204800)
      }
    })
  }

  console.log('✅ Sample audio chunks created')

  console.log('🎉 Database seeded successfully!')
}

main()
  .catch((e) => {
    console.error('❌ Error seeding database:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
