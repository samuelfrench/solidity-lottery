module.exports.waitForEvent = async (eventName, contract) => {
                                let events = await contract.getPastEvents(eventName, { fromBlock: 0, toBlock: 'latest' });
                                let secondCounter = 0;
                                const sleep = (ms) => new Promise((res) => setTimeout(res, ms));
                                while (events.length < 1) {
                                  console.log('waiting for event');
                                  await sleep(1000);
                                  secondCounter++;
                                  events = await contract.getPastEvents(eventName, { fromBlock: 0, toBlock: 'latest' });
                                  if (secondCounter > 100) {
                                    assert(false);
                                  }
                                }
                              };