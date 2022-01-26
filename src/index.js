const b = await (async () => {
	return 3;
})();

export const handler = async (event) => {
	return "called from exported handler! value=" + b;
};
