# Note that this file is both a runnable script and somewhat used as library code.
# This is poor style, but can happen in the real world.

from data_models import Product
from data_persistence import update_stock

import click

def check_stock(product_id: int) -> int:
    #Simulating stock retrieval. In real code this would be from data_persistence.
    return 100 #Placeholder

def adjust_stock(product_id: int, quantity_change: int):
    current_stock = check_stock(product_id)
    new_stock = current_stock + quantity_change
    if new_stock < 0:
        raise ValueError("Insufficient stock")

    update_stock(product_id, new_stock)
    print(f"Adjusted stock for product {product_id} to {new_stock}")


@click.group()
def cli():
    pass

@cli.command("adjust")
def cmd_adjust():
    pass

if __name__ == "__main__":
    cli()
