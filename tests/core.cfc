component extends='testbox.system.BaseSpec' {

	function run() {

		describe( 'Promise.prototype' , function() {

			it( 'throws an error if the first argument is not provided' , function() {

				expect( function() {

					new Promise();

				} ).toThrow( 'expression' );

			} );

			it( 'throws an error if the first argument is not a function' , function() {

				expect( function() {

					new Promise( 'test' );

				} ).toThrow( 'expression' );

			} );

			it( 'has expected keys which are functions with a null value' , function() {

				var actual = new Promise( function() {} );

				expect( actual ).toBeStruct();

				expect( actual ).toHaveKey( 'then' );
				expect( actual.then ).toBeTypeOf( 'function' );

				expect( actual ).toHaveKey( 'catch' );
				expect( actual.catch ).toBeTypeOf( 'function' );

				expect( actual ).toHaveKey( 'done' );
				expect( actual.done ).toBeTypeOf( 'function' );

				expect( actual ).toHaveKey( 'value' );
				expect( actual.done ).toBeTypeOf( 'function' );

				expect( actual ).toHaveKey( 'thread_name' );
				expect( actual.thread_name ).toBeTypeOf( 'string' );

				expect( actual.value() ).toBe( '' );
				expect( actual.done() ).toBe( '' );

			} );

			it( 'returns a value when the callback hits resolve' , function() {

				var actual = new Promise( function( resolve , reject ) {

					resolve( 'resolved' );

				} );

				expect( actual ).toBeTypeOf( 'component' );
				expect( actual ).toBeInstanceOf( 'source.plugins.Promise' );
				expect( actual.done() ).toBe( 'resolved' );

			} );

			it( 'throws an error when the callback hits reject' , function() {


				var actual = new Promise( function( resolve , reject ) {

					reject( 'rejected' );

				} );

				expect( actual ).toBeTypeOf( 'component' );
				expect( actual ).toBeInstanceOf( 'source.plugins.Promise' );

				try {

					actual.done();

					fail( 'Value on a rejected promise not throwing expected error' );

				} catch ( Promise.rejected e ) {

					expect( e.message ).toBe( 'rejected' );

				} catch ( any e ) {

					fail( 'Value on a rejected promise not throwing expected error' );

				}

			} );

			describe( '.then' , function() {

				it( 'hits onFulfilled and returns a value after a resolved promise with data' , function() {

					var actual = Promise::resolve( 'onfulfilled data' )
						.then(
							function( data ) {
								expect( arguments.data ).toBe( 'onfulfilled data' );
								return arguments.data;
							},
							function() {
								fail( 'Not expected to run the onRejected method' );
							}
						)
						.done();

					expect( actual ).toBe( 'onfulfilled data' );

				} );



				it( 'defaults onFulfilled to just return the value from the preceeding promise' , function() {

					var actual = Promise::resolve( 'default onfulfilled data' )
						.then()
						.done();

					expect( actual ).toBe( 'default onfulfilled data' );

				} );

				it( 'hits onRejected and returns a value after a resolved promise with data' , function() {

					var actual = Promise::reject( 'onrejected message' )
						.then(
							function() {
								fail( 'Not expected to run the onFulfilled method' );
							},
							function( error ) {
								expect( arguments.error ).toBe( 'onrejected message' );
								return arguments.error;
							}
						)
						.done();

					expect( actual ).toBe( 'onrejected message' );

				} );

				it( 'defaults onRejected to just rethrow the error from the preceeding promise' , function() {


					var actual = Promise::reject( 'rethrown error' );

					expect( actual ).toBeTypeOf( 'component' );
					expect( actual ).toBeInstanceOf( 'source.plugins.Promise' );

					try {

						actual.then();

						fail( 'Value on a rejected promise not throwing expected error' );

					} catch ( Promise.rejected e ) {

						expect( e.message ).toBe( 'rethrown error' );

					} catch ( any e ) {

						fail( 'Value on a rejected promise not throwing expected error' );

					}

				} );

				it( 'can be chained' , function() {

					var actual = Promise::resolve( [ 1 ] )
						.then(
							function( data ) {
								data.add( 2 );
								return Promise::resolve( data );
							}
						)
						.then(
							function( data ) {
								data.add( 3 );
								return Promise::resolve( data );
							}
						)
						.then(
							function( data ) {
								data.add( 4 );
								return Promise::resolve( data );
							}
						)
						.then(
							function( data ) {
								data.add( 5 );
								return Promise::resolve( data );
							}
						);

					var actual_value = actual.done();

					expect( actual_value ).toBeArray();
					expect( actual_value ).toHaveLength( 5 )

					for ( var i = 1; i <= 5; i++ ) {
						expect( actual_value[ i ] ).toBe( i );
					} 

				} );

				describe( 'onFulfilled' , function() {

					it( 'must return Promise::resolve( return ) when it returns a non-promise' , function() {

						Promise::resolve( 'resolve 1' )
						.then(
							function( data ) {
								return 'resolve 2';
							},
							function( error_message ) {
								fail( 'Should not hit rejected' );
							}
						)
						.then(
							function( data ) {
								expect( data ).toBe( 'resolve 2' );
							},
							function( error_message ) {
								fail( 'Should not hit rejected' );
							}
						);

					} );

					it( 'must return Promise::resolve( data ) when it does not return a value' , function() {
						Promise::resolve( 'resolve 1' )
						.then(
							function( data ) {
								// Nothing much happening
							},
							function( error_message ) {
								fail( 'Should not hit rejected' );
							}
						)
						.then(
							function( data ) {
								expect( data ).toBe( 'resolve 1' );
							},
							function( error_message ) {
								fail( 'Should not hit rejected' );
							}
						);
					} );

					it( 'must return Promise::reject( error_reason ) if it throws an error' , function() {

						Promise::resolve( 'resolve 1' )
						.then(
							function( data ) {
								throw( message = 'onfulfilled throw 1' );
							},
							function( error_message ) {
								fail( 'Should not hit rejected' );
							}
						)
						.then(
							function( data ) {
								fail( 'Should not hit resolved' );
							},
							function( error_message ) {
								expect( error_message ).toBe( 'onfulfilled throw 1' );
							}
						);

					} );

				} );

				describe( 'onRejected' , function() {


					it( 'must return Promise::resolve( return ) when it returns a non-promise' , function() {

						Promise::reject( 'reject 1' )
						.then(
							function( data ) {
								fail( 'Should not hit resolved' );
							},
							function( error_message ) {
								return 'resolve 1';
							}
						)
						.then(
							function( data ) {
								expect( data ).toBe( 'resolve 1' );
							},
							function( error_message ) {
								fail( 'Should not hit rejected' );
							}
						);

					} );

					it( 'must return Promise::reject( data ) when it does not return a value' , function() {

						Promise::reject( 'reject 1' )
						.then(
							function( data ) {
								fail( 'Should not hit resolved' );
							},
							function( error_message ) {
								// Nothing much going on here
							}
						)
						.then(
							function( data ) {
								fail( 'Should not hit resolved' );
							},
							function( error_message ) {
								expect( error_message ).toBe( 'reject 1' )
							}
						);

					} );

					it( 'must return Promise::reject( error_reason ) if it throws an error' , function() {

						Promise::reject( 'reject 1' )
						.then(
							function( data ) {
								fail( 'Should not hit resolved' );
							},
							function( error_message ) {
								throw( message = 'onrejected throw 1' );
							}
						)
						.then(
							function( data ) {
								fail( 'Should not hit resolved' );
							},
							function( error_message ) {
								expect( error_message ).toBe( 'onrejected throw 1' );
							}
						);

					} );

				} );

			} );

			describe( '.catch' , function() {

				it( 'behaves the same as hitting onRejected in a then' , function() {

					var actual = Promise::reject( 'catch message' )
						.catch(
							function( error ) {
								expect( arguments.error ).toBe( 'catch message' );
								return arguments.error;
							}
						)
						.done();

					expect( actual ).toBe( 'catch message' );

				} );

				it( 'defaults in the same way as onRejected in then()' , function() {

					var actual = Promise::reject( 'rethrown catch' );

					expect( actual ).toBeTypeOf( 'component' );
					expect( actual ).toBeInstanceOf( 'source.plugins.Promise' );

					try {

						actual.catch();

						fail( 'Value on a rejected promise not throwing expected error' );

					} catch ( Promise.rejected e ) {

						expect( e.message ).toBe( 'rethrown catch' );

					} catch ( any e ) {

						fail( 'Value on a rejected promise not throwing expected error' );

					}

				} );

				it( 'can be chained' , function() {

					var actual = Promise::resolve( [ 1 ] )
						.then(
							function( data ) {
								data.add( 2 );
								return Promise::resolve( data );
							}
						)
						.then(
							function( data ) {
								data.add( 3 );
								return Promise::resolve( data );
							}
						)
						.then(
							function( data ) {
								data.add( 4 );
								return Promise::resolve( data );
							}
						)
						.then(
							function( data ) {
								data.add( 5 );
								return Promise::resolve( data );
							}
						);

					var actual_value = actual.done();

					expect( actual_value ).toBeArray();
					expect( actual_value ).toHaveLength( 5 )

					for ( var i = 1; i <= 5; i++ ) {
						expect( actual_value[ i ] ).toBe( i );
					} 

				} );


			} );


			describe( '.done' , function() {

				it( 'returns null value if used on a promise that has no value' , function() {

					var actual = new Promise( function() {} );

					expect( actual.done() ).toBe( '' );

				});

				describe( 'on resolve' , function() {

					it( 'returns a value without callback' , function() {

						var actual = Promise::resolve( 'resolve value' )
							.done();

						expect( actual ).toBe( 'resolve value' );

					} );

					it( 'hits onfulfilled and returns the value' , function() {


						var actual = Promise::resolve( 'resolve value' )
							.done(
								function( error_message ) {
									expect( error_message ).toBe( 'resolve value' );
									return 'done value';
								},
								function(){

									fail( 'Not expected to hit onrejected' );

								}
							);

						expect( actual ).toBe( 'done value' );

					} );

				} );

				describe( 'on reject' , function() {

					it( 'throws an error without callback' , function() {

						try {

							Promise::reject( 'reject value' )
								.done();

							fail( 'Value on a rejected promise not throwing expected error' );

						} catch ( Promise.rejected e ) {

							expect( e.message ).toBe( 'reject value' );

						} catch ( any e ) {

							fail( 'Value on a rejected promise not throwing expected error' );

						}

					} );

					it( 'hits onrejected and returns the value' , function() {


						var actual = Promise::reject( 'reject value' )
							.done(
								function(){

									fail( 'Not expected to hit onfulfilled' );

								},
								function( error_message ) {
									expect( error_message ).toBe( 'reject value' );
									return 'done value';
								}
							);

						expect( actual ).toBe( 'done value' );

					} );

				} );

			} );

		});

		describe( 'Promise::race' , function() {


			it( 'to be a function that returns a Promise' , function() {

				expect( Promise::race ).toBeTypeOf( 'function' );

				var actual = Promise::race( [
					Promise::resolve( 'speed racer' )
				] );

				expect( actual ).toBeTypeOf( 'component' );
				expect( actual ).toBeInstanceOf( 'source.plugins.Promise' );

				var actual_value = actual.done();
				expect( actual_value ).toBe( 'speed racer' );

			} );

			it( 'throws an error if the array is empty' , function() {

				try {

					Promise::race( [] );

					fail( 'Race not failing with an empty array' )

				} catch ( Promise.race_is_empty e ) {

					// Working ok

				} catch ( any e ) {

					fail( 'Error thrown by empty error not as expected' );

				}

			} );

			it( 'returns the first element to resolve' , function() {

				var start_ms = GetTickCount();

				var actual = Promise::race( [
						Promise::resolve( 'quick' ),
						new Promise( function( resolve , reject ) {
							sleep( 100 );
							resolve( 'slow' );
						} )
					] )
					.done();

				var time_taken = GetTickCount() - start_ms;
				expect( time_taken ).toBeLT( 99 );

				expect( actual ).toBe( 'quick' );

			} );

			it( 'returns the fastest element to resolve' , function() {

				var start_ms = GetTickCount();

				var actual = Promise::race( [
						new Promise( function( resolve , reject ) {
							sleep( 100 );
							resolve( 'slow' );
						} ),
						Promise::resolve( 'quick' )
					] )
					.done();

				var time_taken = GetTickCount() - start_ms;
				expect( time_taken ).toBeLT( 99 );

				expect( actual ).toBe( 'quick' );

			} );

			it( 'ignores resolves when the reject only flag is true' , function() {

				var start_ms = GetTickCount();


				try {

					Promise::race( 
						iteratable = [
							Promise::resolve( 'quick resolve' ),
							new Promise( function( resolve , reject ) {
								sleep( 100 );
								reject( 'slow reject' );
							} )
						],
						only_declare_rejection_the_winner = true
					)
					.catch();

					fail( 'Race did not reject' );

				} catch ( Promise.rejected e ) {

					expect( e.message ).toBe( 'slow reject' );

				} catch ( any e ) {

					dump( e );
					fail( 'Race rejected with an unexpected error' );

				}

				var time_taken = GetTickCount() - start_ms;
				expect( time_taken ).toBeGT( 99 );

			} );

		} );

		describe( 'Promise::all' , function() {

			it( 'to be a function that returns a Promise' , function() {

				expect( Promise::all ).toBeTypeOf( 'function' );

				var actual = Promise::all( [] );

				expect( actual ).toBeTypeOf( 'component' );
				expect( actual ).toBeInstanceOf( 'source.plugins.Promise' );

				var actual_value = actual.done();

				expect( actual_value ).toBeArray();
				expect( actual_value ).toHaveLength( 0 );

			} );

			it( 'returns values from resolved promises in the order they were provided' , function() {

				var start_ms = GetTickCount();
				var actual = Promise::all( [
					Promise::resolve( 'quick 1' ),
					new Promise( function( resolve , reject ) {
						sleep( 1000 );
						resolve( 'slow 1' );
					} ),
					Promise::resolve( 'quick 2' ),
					new Promise( function( resolve , reject ) {
						sleep( 500 );
						resolve( 'slow 2' );
					} ),
					Promise::resolve( 'quick 3' )
				] );

				var actual_value = actual.done();

				expect( actual_value ).toBeArray();
				expect( actual_value ).toHaveLength( 5 );
				expect( actual_value ).toBe( [
					'quick 1',
					'slow 1',
					'quick 2',
					'slow 2',
					'quick 3'
				] );

				// This will just prove that the threads are executed in series instead of parallel
				var time_taken = GetTickCount() - start_ms;
				expect( time_taken ).toBeGT( 999 ); // Slowest thread is 1000 ms
				expect( time_taken ).toBeLT( 1400 ); // If in parallel, should be at least 1500ms wait

			} );

			it( 'converts non-promises within the array to one and resolves' , function() {

				var actual = Promise::all( [
						Promise::resolve( 'promise 1' ),
						'not a promise',
						Promise::resolve( 'promise 2' )
					] )
					.done();

				expect( actual ).toBe( [
					'promise 1',
					'not a promise',
					'promise 2'
				] );

			} );

			it( 'rejects if anything rejects' , function() {

				var actual = Promise::all( [
						Promise::resolve( 'promise 1' ),
						Promise::reject( 'reject 1' )
					] )
					.then(
						function() {
							fail( 'Not expected to run the onFulfilled method' );
						},
						function( error ) {
							expect( arguments.error ).toBe( 'reject 1' );
							return arguments.error;
						}
					)
					.done();

				expect( actual ).toBe( 'reject 1' );

			} );

			it( 'rejects with the fastest rejection' , function() {

				var start_ms = GetTickCount();

				var actual = Promise::all( [
						new Promise( function( resolve , reject ) {
							sleep( 500 );
							reject( 'slept for 500' );
						} ),
						new Promise( function( resolve , reject ) {
							sleep( 100 );
							reject( 'slept for 100' );
						} )
					] )
					.then(
						function() {
							fail( 'Not expected to run the onFulfilled method' );
						},
						function( error ) {
							expect( arguments.error ).toBe( 'slept for 100' );
							return arguments.error;
						}
					)
					.done();

				var time_taken = GetTickCount() - start_ms;
				expect( time_taken ).toBeGT( 99 );
				expect( time_taken ).toBeLT( 200 ); 



				expect( actual ).toBe( 'slept for 100' );

			} );

		} );

		describe( 'Promise::resolve' , function() {

			it( 'to be a function that returns a Promise' , function() {

				expect( Promise::resolve ).toBeTypeOf( 'function' );

				var actual = Promise::resolve( 'resolved value' );

				expect( actual ).toBeTypeOf( 'component' );
				expect( actual ).toBeInstanceOf( 'source.plugins.Promise' );

				expect( actual.done() ).toBe( 'resolved value' );


			} );

		} );

		describe( 'Promise::reject' , function() {

			it( 'to be a function that returns a Promise' , function() {

				expect( Promise::reject ).toBeTypeOf( 'function' );

				var actual = Promise::reject( 'something funky' );

				expect( actual ).toBeTypeOf( 'component' );
				expect( actual ).toBeInstanceOf( 'source.plugins.Promise' );


				try {

					actual.done();

					fail( 'Value on a rejected promise not throwing expected error' );

				} catch ( Promise.rejected e ) {

					expect( e.message ).toBe( 'something funky' );

				} catch ( any e ) {

					fail( 'Value on a rejected promise not throwing expected error' );

				}

			} );

		} );

	}

}