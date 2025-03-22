import click
from order_processing import create_order, update_order_shipping
from inventory_management import adjust_stock

@click.group()
def cli():
    pass

@cli.command("create-order")
@click.option("--customer-id", type=int, required=True)
@click.option("--items", type=str, required=True) # example: "1:2,2:1"
@click.option("--shipping-address", type=str)
def create_order_cmd(customer_id, items, shipping_address):
    items_list = [(int(item.split(":")[0]), int(item.split(":")[1])) for item in items.split(",")]
    order = create_order(customer_id, items_list, shipping_address)
    click.echo(f"Order created: {order.order_id}")

@cli.command("update-shipping")
@click.option("--order-id", type=int, required=True)
@click.option("--new-address", type=str, required=True)
def update_shipping_cmd(order_id, new_address):
    update_order_shipping(order_id, new_address)
    click.echo(f"Shipping address updated for order {order_id}")

@cli.command("adjust-stock")
@click.option("--product-id", type=int, required=True)
@click.option("--quantity-change", type=int, required=True)
def adjust_stock_cmd(product_id, quantity_change):
    adjust_stock(product_id, quantity_change)
    click.echo(f"Stock adjusted for product {product_id}")

if __name__ == "__main__":
    cli()
