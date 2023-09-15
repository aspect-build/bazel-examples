import { PrismaClient } from './prisma-client';

const main = async () => {
  const client = new PrismaClient();

  await client.myUser.create({
    data: {
      name: 'Bob',
      email: 'bob@example.com',
    },
  });
};

main().catch((err) => console.log(err));
