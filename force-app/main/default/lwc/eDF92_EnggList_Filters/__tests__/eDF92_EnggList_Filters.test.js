import { createElement } from 'lwc';
import EDF92_EnggList_Filters from 'c/eDF92_EnggList_Filters';

describe('c-e-d-f-92-engg-list-filters', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('TODO: test case generated by CLI command, please fill in test logic', () => {
        // Arrange
        const element = createElement('c-e-d-f-92-engg-list-filters', {
            is: EDF92_EnggList_Filters
        });

        // Act
        document.body.appendChild(element);

        // Assert
        // const div = element.shadowRoot.querySelector('div');
        expect(1).toBe(1);
    });
});