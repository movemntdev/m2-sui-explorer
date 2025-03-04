// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

//# init --addresses Test=0x0 A=0x42 --simulator

//# publish
module Test::M1 {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use sui::transfer;

    struct Object has key, store {
        id: UID,
        value: u64,
    }

    public entry fun create(value: u64, recipient: address, ctx: &mut TxContext) {
        transfer::public_transfer(
            Object { id: object::new(ctx), value },
            recipient
        )
    }
}

//# run Test::M1::create --args 0 @A

//# run Test::M1::create --args 1 @A

//# run Test::M1::create --args 2 @A

//# run Test::M1::create --args 3 @A

//# run Test::M1::create --args 4 @A

//# create-checkpoint

//# run-graphql --variables A
{
  # select all objects owned by A
  address(address: $A) {
    objectConnection {
      edges {
        cursor
      }
    }
  }
}

//# run-graphql --variables A
{
  # select the first 2 objects owned by A
  address(address: $A) {
    objectConnection(first: 2) {
      edges {
        cursor
      }
    }
  }
}

//# run-graphql --variables A obj_5_0
{
  address(address: $A) {
    # select the 2nd and 3rd objects
    # note that order does not correspond
    # to order in which objects were created
    objectConnection(first: 2 after: $obj_5_0) {
      edges {
        cursor
      }
    }
  }
}

//# run-graphql --variables A obj_4_0
{
  address(address: $A) {
    # select 4th and last object
    objectConnection(first: 2 after: $obj_4_0) {
      edges {
        cursor
      }
    }
  }
}

//# run-graphql --variables A obj_3_0
{
  address(address: $A) {
    # select 3rd and 4th object
    objectConnection(last: 2 before: $obj_3_0) {
      edges {
        cursor
      }
    }
  }
}
